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

import ballerina/file;
import ballerina/http;
import ballerina/uuid;

# Google Drive Client. 
#
# + httpClient - The HTTP Client
@display {label: "Google Drive Client", iconPath: "GoogleDriveLogo.png"}
public client class Client {
    public http:Client httpClient;
    Configuration driveConfiguration;

    public isolated function init(Configuration driveConfig) returns error? {    
        self.driveConfiguration = driveConfig;
        http:ClientSecureSocket? socketConfig = driveConfig?.secureSocketConfig;
        self.httpClient = check new (BASE_URL, {
            auth: driveConfig.clientConfig,
            secureSocket: socketConfig,
            http1Settings: {chunking: http:CHUNKING_NEVER}
        });
    }

    # Retrieve file using the fileID.
    # 
    # + fileId - ID of the file to retreive
    # + fields - Paths of the fields you want included in the reponse.
    # + return - If successful, returns `File`. Else returns `error`
    @display {label: "Get file"}
    remote isolated function getFile(@display {label: "File id"} string fileId, @display {label: "Fields"} string? fields = ()) 
                            returns @tainted @display {label: "File"} File|error {
        GetFileOptional optional = {};
        optional.supportsAllDrives = true;
        if (fields is string){
            optional.fields = fields;
        }
        return getFileById(self.httpClient, fileId, optional);
    }

    # Download file using the fileID.
    # 
    # + fileId - ID of the file to retreive
    # + return - If successful, returns `string`. Else returns `error`
    @display {label: "Download file"}
    remote isolated function downloadFile(@display {label: "File id to delete"} string fileId) 
                                returns @tainted @display {label: "Downloadable link"} string|error {
        GetFileOptional optional = {supportsAllDrives : true, fields : WEB_CONTENT_LINK};
        File fileResponse = check getFileById(self.httpClient , fileId, optional);
        return fileResponse?.webContentLink.toString();
    }

    # Retrieve files. (To be Deprecated in next release ..)
    # 
    # + optional - 'ListFilesOptional' used to add query parameters to the request
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Get files"}
    remote isolated function getFiles(@display {label: "Optional query parameters"} ListFilesOptional? optional = ()) 
                            returns @tainted @display {label: "File stream"} stream<File>|error {
        if (optional is ListFilesOptional) {
            optional.pageSize = 1000;
            optional.supportsAllDrives = false;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieve all the files in the drive.
    # 
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Get all files"}
    remote isolated function getAllFiles(@display {label: "Filter string (optional)"} string? filterString = ()) 
                                returns @tainted @display {label: "File stream"} stream<File>|error {
        ListFilesOptional optional = {
            pageSize : 1000,
            supportsAllDrives : false
        };
        if (filterString is string) {
            optional.q = filterString;
        }
        return getFiles(self.httpClient, optional);
    }

    # Filter and retreive files using filter string
    # 
    # + filterString - Query used to find what you need. Read documentation for query string patterns.
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Filter files"}
    remote isolated function filterFiles(@display {label: "Filter string"} string filterString,
                                @display {label: "Order by (optional)"} string? orderBy = ()) 
                                returns @tainted @display {label: "Files stream"} stream<File>|error {
        ListFilesOptional optional = {
            q : filterString,
            supportsAllDrives: true,
            includeItemsFromAllDrives: true,
            pageSize: 1000
        };
        if (orderBy is string) {
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieve files by Name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Get files by name"}
    remote isolated function getFilesByName(@display {label: "File name"} string fileName, 
                                   @display {label: "Order by (optional)"} string? orderBy = ())    
                                   returns @tainted @display {label: "File stream"} stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND 
                    + SPACE + TRASH_FALSE;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (orderBy is string) {
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    } 

    # Retrieve all Google spreadsheets
    # 
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Get all spreadsheets"}
    remote isolated function getAllSpreadsheets() returns @tainted @display {label: "File stream"} stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + SHEETS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        return getFiles(self.httpClient, optional);
    }

    # Retrieve Google spreadsheets by Name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Get spreadsheets by name"}
    remote isolated function getSpreadsheetsByName(@display {label: "File name"} string fileName, 
                                          @display {label: "Order by (optional)"} string? orderBy = ()) 
                                          returns @tainted @display {label: "File stream"} stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND 
                                + SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + SHEETS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (orderBy is string) {
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    } 

    # Retrieve Google documents by Name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Get documents by name"}
    remote isolated function getDocumentsByName(@display {label: "File name"} string fileName, 
                                       @display {label: "Order by (optional)"} string? orderBy = ()) 
                                       returns @tainted @display {label: "File stream"} stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND 
                    + SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + DOCS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (orderBy is string) {
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieve Google forms by Name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Get forms by name"}
    remote isolated function getFormsByName(@display {label: "File name"} string fileName, 
                                   @display {label: "Order by (optional)"} string? orderBy = ()) 
                                   returns @tainted @display {label: "File stream"} stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND
                     + SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + FORMS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (orderBy is string) {
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieve Google slides by Name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Get slides by name"}
    remote isolated function getSlidesByName(@display {label: "File name"} string fileName, 
                                    @display {label: "Order by (optional)"} string? orderBy = ()) 
                                    returns @tainted @display {label: "File stream"} stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND
                         + SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + SLIDES;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (orderBy is string) {
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieve folders by Name
    # 
    # + folderName - Name of the folder to search (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'.  
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    @display {label: "Get folders by name"}
    remote isolated function getFoldersByName(@display {label: "Folder name"} string folderName, 
                                     @display {label: "Order by (optional)"} string? orderBy = ()) 
                                     returns @tainted @display {label: "File stream"} stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + folderName + SINGLE_QUOTE + SPACE + AND 
                        +  SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + FOLDERS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (orderBy is string) {
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Delete file using the fileID.
    # 
    # + fileId - ID of the file to delete
    # + return - If successful, returns `boolean` as true. Else returns `error`
    @display {label: "Delete file by id"}
    remote isolated function deleteFile(@display {label: "File id"} string fileId) 
                               returns @tainted @display {label: "Result"} boolean|error {
        DeleteFileOptional deleteOptional = {supportsAllDrives : true};
        return deleteFileById(self.httpClient, fileId, deleteOptional);
    }

    # Copy file using the fileID.
    # 
    # + fileId - ID of the file to copy
    # + destinationFolderId - Folder ID of the destination
    # + newFileName - Name of the New file
    # + return - If successful, returns `File`. Else returns `error`
    @display {label: "Copy file"}
    remote isolated function copyFile(@display {label: "File id"} string fileId, 
                             @display {label: "Destination folder id (optional)"} string? destinationFolderId = (), 
                             @display {label: "New file name (optional)"} string? newFileName = ()) 
                             returns @tainted @display {label: "File"} File|error {
        CopyFileOptional optional = {supportsAllDrives : true};
        File fileResource = {};
        if (newFileName is string){
            fileResource.name = newFileName;
        }
        if (destinationFolderId is string){
            fileResource.parents = [destinationFolderId];
        }
        return copyFile(self.httpClient, fileId, optional, fileResource);
    }

    # Move file using the fileID.
    # 
    # + fileId - ID of the file to move
    # + destinationFolderId - Folder ID of the destination
    # + return - If successful, returns `File`. Else returns `error`
    @display {label: "Move file"} 
    remote isolated function moveFile(@display {label: "File id"} string fileId, 
                             @display {label: "Destination folder id"} string destinationFolderId) 
                             returns @tainted @display {label: "File"} File|error {
        UpdateFileMetadataOptional optionalsFileMetadata = {
            addParents : destinationFolderId
        };
        return updateFileById(self.httpClient, fileId, optionalsFileMetadata);
    }

    # Rename a file
    # 
    # + fileId - File Id that need to be renamed
    # + newFileName - New file name that should be renamed to.
    # + return - If successful, returns `File`. Else returns `error`
    @display {label: "Rename file"} 
    remote isolated function renameFile(@display {label: "File id"} string fileId, 
                               @display {label: "New file name"} string newFileName) 
                               returns @tainted @display {label: "File"} File|error {
        File fileResource = {name : newFileName};
        return updateFileById(self.httpClient, fileId, fileResource);
    }

    # Update file metadata using the fileID.
    # 
    # + fileId - ID of the file to be updated
    # + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
    # + fileResource - 'File' can added as a payload to change metadata
    # + return - If successful, returnsoptionalsFileMetadata `File`. Else returns `error`
    @display {label: "Update file metadata by id"}
    remote isolated function updateFileMetadataById(@display {label: "File id"} string fileId, 
                                           @display {label: "File resource (optional)"} File? fileResource = (), 
                                           @display {label: "Optional parameters"} UpdateFileMetadataOptional? optional = ()) 
                                           returns @tainted @display {label: "File"} File|error {
        return updateFileById(self.httpClient, fileId, fileResource, optional);
    }

    # Create new file.
    # 
    # + optional - 'CreateFileOptional' used to add query parameters to the request
    # + fileData - 'File' Metadata is send to in the payload 
    # + return - If successful, returns `File`. Else returns `error`
    @display {label: "Create metadata file"}
    remote isolated function createMetaDataFile(@display {label: "Optional parameters"} CreateFileOptional? optional = (), 
                                       @display {label: "File data (optional)"} File? fileData = ()) 
                                       returns @tainted @display {label: "File"} File|error {
        return createMetaDataFile(self.httpClient, fileData, optional);
    }

    # Create new file.
    # 
    # + fileName - Name of the new file to be created.
    # + mime - Type of file that is going to create. refer https://developers.google.com/drive/api/v3/mime-types
    #          You need to only specify the last word in the MIME type. 
    #          For an example, If you want to create a Google document.. The value for this parameter should be
    #          "document" .. Google sheets -> "spreadsheet" etc.
    # + folderId - Id of the parent folder that the new file wants to get created. 
    # + return - If successful, returns `File`. Else returns `error`
    @display {label: "Create file"} 
    remote isolated function createFile(@display {label: "File name"} string fileName, 
                               @display {label: "Mime type (optional)"} MimeTypes? mime = (), 
                               @display {label: "Folder id (optional)"} string? folderId = ()) 
                               returns @tainted @display {label: "File"} File|error {
        CreateFileOptional optional = {supportsAllDrives : true};
        File fileData = {name : fileName};
        if (mime is string){
            fileData.mimeType = mime;
        }
        if (folderId is string){
            fileData.parents = [folderId];
        }
        return createMetaDataFile(self.httpClient, fileData, optional);
    }

    # Create new folder.
    # 
    # + folderName - Name of the new folder to be created.
    # + parentFolderId - Id of the parent folder.
    # + return - If successful, returns `File`. Else returns `error`
    @display {label: "Create folder"} 
    remote isolated function createFolder(@display {label: "Folder name"} string folderName, 
                                 @display {label: "Parent folder id (optional)"} string? parentFolderId = ()) 
                                 returns @tainted @display {label: "File"} File|error {
        File fileData = {name : folderName, mimeType : MIME_PREFIX + FOLDER};
        CreateFileOptional optional = {supportsAllDrives : true};
        if (parentFolderId is string){
            fileData.parents = [parentFolderId];
        }
        return createMetaDataFile(self.httpClient, fileData, optional);
    }

    # Upload new file.
    # 
    # + localPath - Path to the file object to be uploaded
    # + fileName - File name for the uploading file (optional). It will take the base name, if not provided.
    # + parentFolderId - Parent folder ID (optional). It will be uploaded to the root, if not provided.
    # + return - If successful, returns `File`. Else returns `error`
    @display {label: "Upload file"} 
    remote isolated function uploadFile(@display {label: "Local path"} string localPath, 
                               @display {label: "File name (optional)"} string? fileName = (), 
                               @display {label: "Parent folder id (optional)"} string? parentFolderId = ()) 
                               returns @tainted @display {label: "File"} File|error {
        string originalFileName = check file:basename(localPath);
        File fileMetadata = {name : originalFileName};
        if (fileName is string) {
            fileMetadata.name = fileName;
        }
        UpdateFileMetadataOptional optional = {};
        if (parentFolderId is string) {
            optional.addParents = parentFolderId;
        }
        return uploadFile(self.httpClient, localPath, fileMetadata, optional);
    }
    
    # Upload new file using a Byte array.
    # 
    # + byteArray - Byte array that represents the file object
    # + fileName - File name for the uploading file (optional). It will take the base name, if not provided.
    # + parentFolderId - Parent folder ID (optional). It will be uploaded to the root, if not provided.
    # + return - If successful, returns `File`. Else returns `error`
    @display {label: "Upload file using byte array"} 
    remote isolated function uploadFileUsingByteArray(@display {label: "Byte array"} byte[] byteArray, 
                                             @display {label: "File name"} string fileName, 
                                             @display {label: "Parent folder id (optional)"} 
                                             string? parentFolderId = ()) 
                                             returns @tainted @display {label: "File"} File|error {
        File fileMetadata = {name : fileName};
        UpdateFileMetadataOptional optional = {};
        if (parentFolderId is string){
            optional.addParents = parentFolderId;
        }
        return uploadFileUsingByteArray(self.httpClient, byteArray, fileMetadata, optional);
    }

    # Gets information about the user, the user's Drive, and system capabilities.
    # 
    # + fields - The paths of the fields you want included in the response
    # + return - If successful, returns `About`. Else returns `error`
    @display {label: "Get information about drive"} 
    remote isolated function getAbout(@display {label: "Fields (optional)"} string? fields) 
                             returns @tainted @display {label: "About"} About|error {
        return getDriveInfo(self.httpClient , fields);
    }

    # Subscribes to in a specific file.
    # 
    # + fileId - Id of the file that needs to be subscribed for watching.
    # + address - The address where notifications are delivered for this channel.
    # + expiration - The expiration time
    # + return - If successful, returns `WatchResponse`. Else returns `error` 
    @display {label: "Watch specific using file id"} 
    remote isolated function watchFilesById(@display {label: "File id"} string fileId, 
                                   @display {label: "Address"} string address, 
                                   @display {label: "Page token (optional)"} string? pageToken = (), 
                                   @display {label: "Expiration timestamp (optional)"} int? expiration = ()) 
                                   returns @tainted @display {label: "Watch response"} WatchResponse|error {
        WatchResponse payload = {};
        payload.id = uuid:createType1AsString();
        string token = EMPTY_STRING;
        payload.'type = WEB_HOOK;
        payload.address = address;
        if (expiration is int) {
            payload.expiration = expiration;
        }
        if (pageToken is ()) {
            token = check getStartPageToken(self.httpClient);
        } else {
            token = pageToken;
        }
        WatchFileOptional optional = {supportsAllDrives : true, pageToken : token};
        return watchFilesById(self.httpClient, fileId, payload, optional);
    }

    # Subscribes to changes in all files.
    # 
    # + address - The address where notifications are delivered for this channel.
    # + pageToken - 
    # + expiration - 
    # + return - If successful, returns `WatchResponse`. Else returns `error`
    @display {label: "Watch all files"} 
    remote isolated function watchFiles(@display {label: "Address"} string address, 
                               @display {label: "Page token (optional)"} string? pageToken = (), 
                               @display {label: "Expiration timestamp (optional)"} int? expiration = ()) 
                               returns @tainted @display {label: "Watch response"} WatchResponse|error {
        WatchResponse payload = {};
        WatchFileOptional optional = {};
        string token = EMPTY_STRING;
        payload.id = uuid:createType1AsString();
        payload.'type = WEB_HOOK;
        payload.address = address;
        if (expiration is int) {
            payload.expiration = expiration;
        }
        if (pageToken is ()) {
            token = check getStartPageToken(self.httpClient);
        } else {
            token = pageToken;
        }
        optional = {pageToken : token};
        return watchAllFiles(self.httpClient, payload, optional);
    }

    # Stop watching resources through this channel.
    # 
    # + channelId - A UUID or similar unique string that identifies this channel.
    # + resourceId - An opaque ID that identifies the resource being watched on this channel.
    #                Stable across different API versions.
    # + return - If successful, returns `boolean`. Else returns `error`.
    @display {label: "Stop all channels"} 
    remote isolated function watchStop(@display {label: "Channel id"} string channelId, @display {label: "Resource id"} string resourceId) 
                              returns @tainted @display {label: "Result"} boolean|error {
        WatchResponse payload = {};
        payload.id = channelId;
        payload.resourceId = resourceId;
        return stopWatch(self.httpClient, payload);
    }

    # Lists the changes for a user or shared drive.
    # 
    # + pageToken - The token for continuing a previous list request on the next page. 
    #               This should be set to the value of 'nextPageToken' from the previous response or to the response 
    #               from the getStartPageToken method.
    # + optional - 'ChangesListOptional' object with optionals.
    # + return - If successful, returns `ChangesListResponse`. Else returns `error`.
    @display {label: "Get list of changes"} 
    remote isolated function listChanges(@display {label: "Page token"} string pageToken, 
                                @display {label: "Optional parameters"} ChangesListOptional? optional = ()) 
                                returns @tainted @display {label: "Changes list"} ChangesListResponse|error {
        return listChangesByPageToken(self.httpClient, pageToken, optional);
    }
} 
