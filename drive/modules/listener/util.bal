// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/googleapis_drive as drive;
import ballerina/log;
import ballerina/time;

# Subscribes to all the changes or specific fileId.
# + callbackURL - Registered callback URL of the 
# + driveClient - Google drive client.
# + fileId - FileId that you want to initiate watch operations. Optional. 
#            Dont specify if you want TO trigger the listener for all the changes.
# + return - 'drive:WatchResponse' on success and error if unsuccessful. 
isolated function startWatch(string callbackURL, drive:Client driveClient, string? fileId = ()) 
                        returns @tainted drive:WatchResponse|error {
    if (fileId is string) {
        // Watch for specified file changes
        return driveClient->watchFilesById(fileId, callbackURL);
    } else {
        // Watch for all file changes.
        return driveClient->watchFiles(callbackURL);
    }
}

# List changes by page token
# + driveClient - The HTTP Client
# + pageToken - The token for continuing a previous list request on the next page. This should be set to the value of 
#               'nextPageToken' from the previous response or to the response from the getStartPageToken method.
# + return - 'drive:ChangesListResponse[]' on success and error if unsuccessful. 
isolated function getAllChangeList(string pageToken, drive:Client driveClient) 
                          returns @tainted drive:ChangesListResponse[]|error {
    drive:ChangesListResponse[] changeList = [];
    string? token = pageToken;
    while (token is string) {
        drive:ChangesListResponse response = check driveClient->listChanges(pageToken);
        changeList.push(response);
        token = response?.nextPageToken;
    }
    return changeList;
}

# Maps Events to Change records
# + changeList - 'ChangesListResponse' record that contains the whole changeList.
# + driveClient - Http client for client connection.
# + eventService - 'OnEventService' record that represents all events.
# + return - if unsucessful, returns error. 
isolated function mapEvents(drive:ChangesListResponse changeList, drive:Client driveClient,SimpleHttpService eventService) returns @tainted error? {
    drive:Change[]? changes = changeList?.changes;
    if (changes is drive:Change[] && changes.length() > 0) {
        foreach drive:Change changeLog in changes {
            string fileOrFolderId = changeLog?.fileId.toString();
            string changeTime = changeLog?.time.toString();
            EventInfo eventInfo = {fileOrFolderId:fileOrFolderId};
            drive:File|error fileOrFolder = driveClient->getFile(fileOrFolderId);
            string mimeType = changeLog?.file?.mimeType.toString();
            if (changeLog?.removed == true) {
                check callOnDeleteMethod(eventService, eventInfo);
            }
            else if (mimeType != FOLDER) {
                log:printDebug("File change event found file id : " + fileOrFolderId + " | Mime type : " +mimeType);
                check identifyFileEvent(fileOrFolderId, changeTime, eventService, driveClient);
            } else {
                log:printDebug("Folder change event found folder id : " + fileOrFolderId + " | Mime type : " +mimeType);
                check identifyFolderEvent(fileOrFolderId, changeTime, eventService, driveClient);
            }
        }
    }
}

# Maps and identify folder change events.
# + folderId - folderId that subjected to a change. 
# + driveClient - Http client for client connection.
# + eventService - 'OnEventService' record that represents all events.
# + return - if unsucessful, returns error. 
isolated function identifyFolderEvent(string folderId, string changeTime, SimpleHttpService eventService, drive:Client driveClient, 
                             boolean isSepcificFolder = false, string? specFolderId = ()) returns @tainted error? {
    drive:File folder = check driveClient->getFile(folderId, "createdTime,modifiedTime,trashed,parents");
    log:printInfo(folder.toString());
    boolean? isTrashed = folder?.trashed;
    string createdTime = folder?.createdTime.toString();
    string[]? parentList = folder?.parents;
    string parent = EMPTY_STRING;
    EventInfo eventInfo = {fileOrFolderId:folderId};
    if (parentList is string[] && parentList.length() > 0) {
        parent = parentList[0].toString();
    }
    if (isSepcificFolder && parent == specFolderId.toString()) {
         if (check isCreated(createdTime, changeTime)) {
            check callOnFolderCreateMethod(eventService, eventInfo);                               
        } else if (isTrashed is boolean && isTrashed) {
            check callOnTrashMethod(eventService, eventInfo);
        } else if (check isUpdated(createdTime, changeTime)) {
            check callOnFolderUpdateMethod(eventService, eventInfo);
        }
    } else if (!isSepcificFolder) {
        if (check isCreated(createdTime, changeTime)) {
            check callOnFolderCreateMethod(eventService, eventInfo);                               
        } else if (isTrashed is boolean && isTrashed) {
            check callOnTrashMethod(eventService, eventInfo);
        } else if (check isUpdated(createdTime, changeTime)) {
            check callOnFolderUpdateMethod(eventService, eventInfo);
        }
    }
}

# Maps and identify file change events.
# + fileId - fileId that subjected to a change. 
# + driveClient - Http client for client connection.
# + eventService - 'OnEventService' record that represents all events.
# + return - if unsucessful, returns error. 
isolated function identifyFileEvent(string fileId, string changeTime, SimpleHttpService eventService, drive:Client driveClient, 
                           boolean isSepcificFolder = false, string? specFolderId = ()) returns @tainted error? {
    drive:File file = check driveClient->getFile(fileId, "createdTime,modifiedTime,trashed,parents");
    // boolean isExisitingFile = check checkAvailability(fileId, statusStore); // Check 404
    boolean? isTrashed = file?.trashed;
    string[]? parentList = file?.parents;
    string createdTime = file?.createdTime.toString();
    string parent = EMPTY_STRING;
    EventInfo eventInfo = {fileOrFolderId:fileId};
    if (parentList is string[] && parentList.length() > 0) {
        parent = parentList[0].toString();
    }
    if (isSepcificFolder && parent == specFolderId.toString()) {
        if (check isCreated(createdTime, changeTime)) {
            // if (isSepcificFolder && parent == specFolderId.toString()) {
                // _ = eventService.onNewFileCreatedInSpecificFolderEvent(fileId);
                // check callOnFileCreateOnSpecificFolderMethod(eventService, eventInfo);
            // } else if (!isSepcificFolder) {
                // _ = eventService.onNewFileCreatedEvent(fileId);
            check callOnFileCreateMethod(eventService, eventInfo);                               
            // }
        } else if (isTrashed is boolean && isTrashed) {
            // if (isSepcificFolder && parent == specFolderId.toString()) {
            //     // _ = eventService.onFileDeletedInSpecificFolderEvent(fileId);
            //     check callOnFileDeleteOnSpecificFolderMethod(eventService, eventInfo);
            // } else if (!isSepcificFolder) {
                check callOnTrashMethod(eventService, eventInfo);
                // _ = eventService.onFileDeletedEvent(fileId);
            // }
        } else if (check isUpdated(createdTime, changeTime)) {
            // if (isSepcificFolder && parent == specFolderId.toString()) {
            //     check callOnFileUpdateOnSpecificFolderMethod(eventService, eventInfo);
            // } else if (!isSepcificFolder) {
            //     log:printInfo(eventInfo.toString());
            check callOnFileUpdateMethod(eventService, eventInfo);
            // }
        }
    } else if (!isSepcificFolder) {
        if (check isCreated(createdTime, changeTime)) {
            check callOnFileCreateMethod(eventService, eventInfo);                               
        } else if (isTrashed is boolean && isTrashed) {
            check callOnTrashMethod(eventService, eventInfo);
        } else if (check isUpdated(createdTime, changeTime)) {
            check callOnFileUpdateMethod(eventService, eventInfo);
        }
    }
}

isolated function isCreated(string createdTime, string changeTime) returns boolean|error{
    boolean isCreated = false;
    time:Utc createdTimeUNIX = check time:utcFromString(createdTime);
    time:Utc changeTimeUNIX = check time:utcFromString(changeTime);
    time:Seconds due = time:utcDiffSeconds(changeTimeUNIX, createdTimeUNIX);
    log:printInfo(">>>>>>>>>>>> DUE : " +due.toString());
    if (due <= 10d) {
        log:printInfo(">>>>>>>>>>>> CREATED TIME : " +createdTime);
        log:printInfo(">>>>>>>>>>>> CHANGE TIME : " +changeTime);
        log:printInfo(">>>>>>>>>>>> CREATED EVENT >>>>>>>>>");
        isCreated = true;
    }
    return isCreated;
}

isolated function isUpdated(string createdTime, string changeTime) returns boolean|error {
    boolean isModified = false;
    time:Utc createdTimeUNIX = check time:utcFromString(createdTime);
    time:Utc changeTimeUNIX = check time:utcFromString(changeTime);
    time:Seconds due = time:utcDiffSeconds(changeTimeUNIX, createdTimeUNIX);
    log:printInfo(">>>>>>>>>>>> DUE : " +due.toString());
    if (due > 10d) {
        log:printInfo(">>>>>>>>>>>> CREATED TIME : " +createdTime);
        log:printInfo(">>>>>>>>>>>> CHANGE TIME : " +changeTime);
        log:printInfo(">>>>>>>>>>>> UPDATED EVENT >>>>>>>>>");
        isModified = true;
    }
    return isModified;
}


# Get current status of a drive. 
# 
# + driveClient - Http client for Drive connection. 
# + optionalSearch - 'ListFilesOptional' object that is used during listing objects in drive.
# + curretStatus - JSON that carries the current status.
public function getAllMetaData(drive:Client driveClient, drive:ListFilesOptional optionalSearch, json[] curretStatus) {
    stream<drive:File>|error res = driveClient->getFiles(optionalSearch);
    if (res is stream<drive:File>) {
        error? e = res.forEach(function(drive:File file) {
                                   json output = checkpanic file.cloneWithType(json);
                                   curretStatus.push(output);
                               });
    }
}

// # Get current status of a drive. 
// # 
// # + driveClient - Http client for Drive connection. 
// # + curretStatus - JSON that carries the current status / Empty JSON (optional).
// # + resourceId - An opaque ID that identifies the resource being watched on this channel.
// #                Stable across different API versions (optional).
// # + return - If unsuccessful, return error.
// function getCurrentStatusOfDrive(drive:Client driveClient, json[] curretStatus, string? resourceId = ()) 
//                                  returns @tainted error? {
//     curretStatus.removeAll();
//     if (resourceId is ()) {
//         drive:ListFilesOptional optionalSearch = {pageSize: 1000, q : "trashed = false"};
//         getAllMetaData(driveClient, optionalSearch, curretStatus);
//     } else {
//         drive:File response = check driveClient->getFile(resourceId);
//         json output = check response.cloneWithType(json);
//         string query = "'" + resourceId + "' in parents";
//         if (response?.mimeType.toString() == FOLDER) {
//             drive:ListFilesOptional optionalSearch = {
//                 pageSize: 1000,
//                 q: query
//             };
//             getAllMetaData(driveClient, optionalSearch, curretStatus);
//         } else {
//             curretStatus.push(output);
//         }
//     }
//     log:printInfo(curretStatus.length().toString());
// }

// # Get current status of a resource. 
// # 
// # + driveClient - Http client for Drive connection.  
// # + curretStatus - JSON that carries the current status of the file.
// # + resourceId - An opaque ID that identifies the resource being watched on this channel.
// #                Stable across different API versions.
// # + return - If unsuccessful, return error.
// isolated function getCurrentStatusOfFile(drive:Client driveClient, json[] curretStatus, string resourceId) 
//                                 returns @tainted error? {
//     curretStatus.removeAll();
//     drive:File response = check driveClient->getFile(resourceId, "createdTime,modifiedTime,trashed");
//     json output = check response.cloneWithType(json);
//     curretStatus.push(output);
// }

// # Validate the existence of a particular resource in a JSON provided.
// # 
// # + itemID - Id that uniquely represents a resource. 
// # + statusStore - JSON object to check the existence of the provided item.
// # + return - If it is available, returns boolean(true). Else error.
// isolated function checkAvailability(string itemID, json[] statusStore) returns boolean|error {
//     boolean flag = false;
//     foreach json item in statusStore {
//         json|error id = item.id;
//         if (id is json) {
//             if (id.toString() == itemID) {
//                 flag = true;
//                 break;
//             }
//         } else {
//             fail error("error in searching on local status");
//         }
//     }
//     return flag;
// }

# Validate for the existence of resources
# 
# + folderId - Id that uniquely represents a folder. 
# + driveClient - Drive connecter client.
# + return - If unsuccessful, return error.
isolated function validateSpecificFolderExsistence(string folderId, drive:Client driveClient) returns @tainted error? {
    drive:File folder = check driveClient->getFile(folderId, 
    "createdTime,modifiedTime,trashed,viewedByMeTime,viewedByMe");
    if (folder?.trashed == true) {
        fail error("Specific folder/file with Id :" + folderId + "had been removed to trashed");
    }
}

# Checks for a modified resource.
# 
# + resourceId - An opaque ID that identifies the resource being watched on this channel.
#                Stable across different API versions. 
# + changeList - Record which maps the response from list changes request.
# + driveClient - Drive connecter client.
# + eventService - 'OnEventService' object.
# + return - If unsuccessful, return error.
isolated function mapEventForSpecificResource(string resourceId, drive:ChangesListResponse changeList, drive:Client driveClient, 
                                     SimpleHttpService eventService) returns @tainted error? {
    drive:Change[]? changes = changeList?.changes;
    if (changes is drive:Change[] && changes.length() > 0) {
        foreach drive:Change changeLog in changes {
            string fileOrFolderId = changeLog?.fileId.toString();
            EventInfo eventInfo = {fileOrFolderId:fileOrFolderId};
            string changeTime = changeLog?.time.toString();
            string mimeType = changeLog?.file?.mimeType.toString();
            if (mimeType != FOLDER) {
                check identifyFileEvent(fileOrFolderId, changeTime, eventService, driveClient, true, resourceId);
            } else {
                check identifyFolderEvent(fileOrFolderId, changeTime, eventService, driveClient, true, resourceId);
            }
        }
    }
}

# Checks for a modified resource.
# 
# + resourceId - An opaque ID that identifies the resource being watched on this channel.
#                Stable across different API versions. 
# + changeList - Record which maps the response from list changes request.
# + driveClient - Drive connecter client
# + eventService - 'OnEventService' object 
# + return - If it is modified, returns boolean(true). Else error.
isolated function mapFileUpdateEvents(string resourceId, drive:ChangesListResponse changeList, drive:Client driveClient, 
                             SimpleHttpService eventService) returns @tainted error? {
    drive:Change[]? changes = changeList?.changes;
    if (changes is drive:Change[] && changes.length() > 0) {
        foreach drive:Change changeLog in changes {
            string fileOrFolderId = changeLog?.fileId.toString();
            string changeTime = changeLog?.time.toString();
            EventInfo eventInfo = {fileOrFolderId:fileOrFolderId};        
            if (fileOrFolderId == resourceId) {
                drive:File file = check driveClient->getFile(fileOrFolderId, "createdTime,modifiedTime,trashed");
                string createdTime = file?.createdTime.toString();
                boolean? istrashed = file?.trashed;
                if (istrashed == true) {
                    check callOnTrashMethod(eventService, eventInfo);
                } else if (check isUpdated(createdTime, changeTime)) {
                    check callOnFileUpdateMethod(eventService, eventInfo);
                }
            }
        }
    }
}

// # Checks for a modified resource.
// # 
// # + eventTime - Drive client connecter. 
// # + lastRecordedTime - The Folder Id for the parent folder.
// # + return - If it is modified, returns boolean(true). Else error.
// isolated function checkforModificationAftertheLastOne(string eventTime, string lastRecordedTime) returns boolean|error {
//     boolean isModified = false;
//     time:Utc eventTimeUNIX = check time:utcFromString(eventTime);
//     time:Utc lastRecordedTimeUNIX = check time:utcFromString(lastRecordedTime);
//     time:Seconds due = time:utcDiffSeconds(eventTimeUNIX, lastRecordedTimeUNIX);
//     if (due < 0d) {
//         isModified = true;
//     }
//     return isModified;
// }

# Checking the MimeType to find folder. 
# 
# + driveClient - Drive client connecter. 
# + specificParentFolderId - The Folder Id for the parent folder.
# + return - If successful, returns boolean. Else error.
isolated function checkMimeType(drive:Client driveClient, string specificParentFolderId) returns @tainted boolean|error {
    drive:File item = check driveClient->getFile(specificParentFolderId, "mimeType,trashed");
    if (item?.mimeType.toString() == FOLDER) {
        return true;
    } else {
        if (item?.trashed == true) {
            fail error("Already trashed file :" + specificParentFolderId);
        } else {
            return false;
        }

    }
}