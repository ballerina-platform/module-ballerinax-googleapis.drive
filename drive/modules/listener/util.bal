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

import ballerinax/googleapis.drive as drive;
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

# Stop all subscriptions for listening.
# + driveClient - Google drive client
# + channelUuid - UUID or other unique string you provided to identify this notification channel
# + watchResourceId - An opaque value that identifies the watched resource
# 
# + return - Returns error, if unsuccessful.
isolated function stopWatchChannel(drive:Client driveClient, string channelUuid, string watchResourceId) 
                                   returns @tainted error? {
    boolean|error response = driveClient->watchStop(channelUuid, watchResourceId);
    if (response is boolean) {
        log:printInfo("Watch channel stopped");
        return;
    } else {
        log:printInfo("Watch channel was not stopped");
        return response;
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
#
# + changeList - 'ChangesListResponse' record that contains the whole changeList.  
# + driveClient - Http client for client connection.  
# + eventService - Http service object   
# + methods - Methods
# + return - if unsucessful, returns error.
isolated function mapEvents(drive:ChangesListResponse changeList, drive:Client driveClient,
                            SimpleHttpService eventService, MethodNames methods) returns @tainted error? {
    drive:Change[]? changes = changeList?.changes;
    if (changes is drive:Change[] && changes.length() > 0) {
        foreach drive:Change changeLog in changes {
            string fileOrFolderId = changeLog?.fileId.toString();
            drive:File|error fileOrFolder = driveClient->getFile(fileOrFolderId);
            string mimeType = changeLog?.file?.mimeType.toString();
            if (changeLog?.removed == true && methods.isOnDelete) {
                check callOnDeleteMethod(eventService, changeLog);
            }
            else if (mimeType != FOLDER) {
                log:printDebug("File change event found file id : " + fileOrFolderId + " | Mime type : " +mimeType);
                check identifyFileEvent(fileOrFolderId, changeLog, eventService, driveClient, methods);
            } else {
                log:printDebug("Folder change event found folder id : " + fileOrFolderId + " | Mime type : " +mimeType);
                check identifyFolderEvent(fileOrFolderId, changeLog, eventService, driveClient, methods);
            }
        }
    }
}

# Maps and identify folder change events.
#
# + folderId - folderId that subjected to a change.   
# + changeLog - Change log  
# + eventService - Http service object   
# + driveClient - Http client for client connection.  
# + methods - Methods  
# + isSepcificFolder - Is specific Folder  
# + specFolderId - Spec folder ID
# + return - if unsucessful, returns error.
isolated function identifyFolderEvent(string folderId, drive:Change changeLog, SimpleHttpService eventService, 
        drive:Client driveClient, MethodNames methods, boolean isSepcificFolder = false, string? specFolderId = ()) 
        returns @tainted error? {
    drive:File folder = check driveClient->getFile(folderId, "createdTime,modifiedTime,trashed,parents");
    string changeTime = changeLog?.time.toString();
    boolean? isTrashed = folder?.trashed;
    string createdTime = folder?.createdTime.toString();
    string[]? parentList = folder?.parents;
    string parent = EMPTY_STRING;
    if (parentList is string[] && parentList.length() > 0) {
        parent = parentList[0].toString();
    }
    if (isSepcificFolder && parent == specFolderId.toString()) {
         if (check isCreated(createdTime, changeTime) && methods.isOnNewFolderCreate) {
            check callOnFolderCreateMethod(eventService, changeLog);                               
        } else if (isTrashed is boolean && isTrashed && methods.isOnFolderTrash) {
            check callOnFolderTrashMethod(eventService, changeLog);
        } else if (check isUpdated(createdTime, changeTime) && methods.isOnFolderUpdate) {
            check callOnFolderUpdateMethod(eventService, changeLog);
        }
    } else if (!isSepcificFolder) {
        if (check isCreated(createdTime, changeTime) && methods.isOnNewFolderCreate) {
            check callOnFolderCreateMethod(eventService, changeLog);                               
        } else if (isTrashed is boolean && isTrashed && methods.isOnFolderTrash) {
            check callOnFolderTrashMethod(eventService, changeLog);
        } else if (check isUpdated(createdTime, changeTime) && methods.isOnFolderUpdate) {
            check callOnFolderUpdateMethod(eventService, changeLog);
        }
    }
}

# Maps and identify file change events.
#
# + fileId - fileId that subjected to a change.   
# + changeLog - Change log  
# + eventService - Http service object   
# + driveClient - Http client for client connection.  
# + methods - Methods  
# + isSepcificFolder - Is specific folder  
# + specFolderId - Spec folder ID
# + return - if unsucessful, returns error.
isolated function identifyFileEvent(string fileId, drive:Change changeLog, SimpleHttpService eventService, 
        drive:Client driveClient, MethodNames methods, boolean isSepcificFolder = false, string? specFolderId = ()) 
        returns @tainted error? {
    drive:File file = check driveClient->getFile(fileId, "createdTime,modifiedTime,trashed,parents");
    string changeTime = changeLog?.time.toString();
    boolean? isTrashed = file?.trashed;
    string[]? parentList = file?.parents;
    string createdTime = file?.createdTime.toString();
    string parent = EMPTY_STRING;
    if (parentList is string[] && parentList.length() > 0) {
        parent = parentList[0].toString();
    }
    if (isSepcificFolder && parent == specFolderId.toString()) {
        if (check isCreated(createdTime, changeTime) && methods.isOnNewFileCreate) {
            check callOnFileCreateMethod(eventService, changeLog);                               
        } else if (isTrashed is boolean && isTrashed && methods.isOnFileTrash) {
            check callOnFileTrashMethod(eventService, changeLog);
        } else if (check isUpdated(createdTime, changeTime) && methods.isOnFileUpdate) {
            check callOnFileUpdateMethod(eventService, changeLog);
        }
    } else if (!isSepcificFolder) {
        if (check isCreated(createdTime, changeTime) && methods.isOnNewFileCreate) {
            check callOnFileCreateMethod(eventService, changeLog);                               
        } else if (isTrashed is boolean && isTrashed && methods.isOnFileTrash) {
            check callOnFileTrashMethod(eventService, changeLog);
        } else if (check isUpdated(createdTime, changeTime) && methods.isOnFileUpdate) {
            check callOnFileUpdateMethod(eventService, changeLog);
        }
    }
}

isolated function isCreated(string createdTime, string changeTime) returns boolean|error{
    boolean isCreated = false;
    time:Utc createdTimeUNIX = check time:utcFromString(createdTime);
    time:Utc changeTimeUNIX = check time:utcFromString(changeTime);
    time:Seconds due = time:utcDiffSeconds(changeTimeUNIX, createdTimeUNIX);
    log:printDebug("Due : " +due.toString());
    if (due <= 12d) {
        isCreated = true;
    }
    return isCreated;
}

isolated function isUpdated(string createdTime, string changeTime) returns boolean|error {
    boolean isModified = false;
    time:Utc createdTimeUNIX = check time:utcFromString(createdTime);
    time:Utc changeTimeUNIX = check time:utcFromString(changeTime);
    time:Seconds due = time:utcDiffSeconds(changeTimeUNIX, createdTimeUNIX);
    log:printDebug("Due : " +due.toString());
    if (due > 12d) {
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
# + methods - Methods
# + return - If unsuccessful, return error.
isolated function mapEventForSpecificResource(string resourceId, drive:ChangesListResponse changeList, 
                                    drive:Client driveClient, SimpleHttpService eventService, MethodNames methods) 
                                    returns @tainted error? {
    drive:Change[]? changes = changeList?.changes;
    if (changes is drive:Change[] && changes.length() > 0) {
        foreach drive:Change changeLog in changes {
            string fileOrFolderId = changeLog?.fileId.toString();
            string changeTime = changeLog?.time.toString();
            string mimeType = changeLog?.file?.mimeType.toString();
            if (mimeType != FOLDER) {
                check identifyFileEvent(fileOrFolderId, changeLog, eventService, driveClient, methods, true, 
                resourceId);
            } else {
                check identifyFolderEvent(fileOrFolderId, changeLog, eventService, driveClient, methods, true, 
                resourceId);
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
# + methods - Methods
# + return - If it is modified, returns boolean(true). Else error.
isolated function mapFileUpdateEvents(string resourceId, drive:ChangesListResponse changeList, drive:Client driveClient, 
                                        SimpleHttpService eventService, MethodNames methods) returns @tainted error? {
    drive:Change[]? changes = changeList?.changes;
    if (changes is drive:Change[] && changes.length() > 0) {
        foreach drive:Change changeLog in changes {
            string fileOrFolderId = changeLog?.fileId.toString();
            string changeTime = changeLog?.time.toString();       
            if (fileOrFolderId == resourceId) {
                drive:File file = check driveClient->getFile(fileOrFolderId, "createdTime,modifiedTime,trashed");
                string createdTime = file?.createdTime.toString();
                boolean? istrashed = file?.trashed;
                if (istrashed == true && methods.isOnFileTrash) {
                    check callOnFileTrashMethod(eventService, changeLog);
                } else if (check isUpdated(createdTime, changeTime) && methods.isOnFileUpdate) {
                    check callOnFileUpdateMethod(eventService, changeLog);
                }
            }
        }
    }
}

# Checking the MimeType to find folder. 
# 
# + driveClient - Drive client connecter. 
# + specificParentFolderId - The Folder Id for the parent folder.
# + return - If successful, returns boolean. Else error.
isolated function checkMimeType(drive:Client driveClient, string specificParentFolderId) 
                                    returns @tainted boolean|error {
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
