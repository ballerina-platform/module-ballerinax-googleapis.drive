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
import ballerinax/'client.config;

# Ballerina Google Drive connector provides capability to programmatically manage files and folders.
# Google Drive API provides operations related to files, channels and changes in Google Drive.
#
# + httpClient - The HTTP Client
@display {label: "Google Drive", iconPath: "icon.png"}
public isolated client class Client {
    final http:Client httpClient;

    # Initialize the connector.
    #
    # + config -  Configurations required to initialize the `Client`
    # + return - An error on failure of initialization or else `()`
    public isolated function init(ConnectionConfig driveConfig) returns error? {
        ConnectionConfig connectionConfig = driveConfig;
        connectionConfig.http1Settings = {chunking: http:CHUNKING_NEVER};
        http:ClientConfiguration httpClientConfig = check config:constructHTTPClientConfig(driveConfig);
        self.httpClient = check new (BASE_URL, httpClientConfig);
    }   

    # Retrieves file using the file ID.
    # 
    # + fileId - ID of the file to retrieve
    # + fields - The paths of the fields you want included in the response
    # + return - If successful, `File`. Else an `error`
    @display {label: "Get File"}
    remote isolated function getFile(@display {label: "File ID"} string fileId, 
                                     @display {label: "Fields"} string? fields = ()) 
                                     returns @tainted File|error {
        GetFileOptional optional = {};
        optional.supportsAllDrives = true;
        if (fields is string){
            optional.fields = fields;
        }
        return getFileById(self.httpClient, fileId, optional);
    }

    # Retrieves file content using the fileId.
    # 
    # + fileId - Id of the file to retrieve file content
    # + return - If successful, `FileContent`. Else an `error`
    @display {label: "Get File Content"}
    remote isolated function getFileContent(@display {label: "File ID"} string fileId) returns FileContent|error {
        GetFileOptional optional = {};
        optional.supportsAllDrives = true;
        optional.alt = MEDIA;
        return check generateRecordFileContent(self.httpClient, prepareUrlWithFileOptional(fileId, optional));
    }

    # Downloads file using the fileId.
    # 
    # + fileId - ID of the file to retrieve
    # + return - If successful, downloadable link value. Else an `error`
    @display {label: "Download File"}
    remote isolated function downloadFile(@display {label: "File ID"} string fileId) 
                                returns @tainted @display {label: "Downloadable Link"} string|error {
        GetFileOptional optional = {supportsAllDrives : true, fields : WEB_CONTENT_LINK};
        File fileResponse = check getFileById(self.httpClient , fileId, optional);
        return fileResponse?.webContentLink.toString();
    }

    # Exports file using the fileId.
    #
    # + fileId - ID of the file to retrieve
    # + mimeType - MIME type of the file to be exported
    # + return - If successful, `FileContent`. Else an `error`
    @display {label: "Export File"}
    remote isolated function exportFile(@display {label: "File ID"} string fileId,
            @display {label: "MIME Type"} string mimeType)
                                    returns FileContent|error {
        string path = prepareExportUrl(fileId, mimeType);
        return generateRecordFileContent(self.httpClient, path);
    }

    # Retrieves all the files in the drive.
    # 
    # + filterString - Query used to find what you need. Read documentation for query string patterns.
    #                  https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/blob/main/drive/README.md#filter-files
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, stream of files `stream<File>`. Else an `error`
    @display {label: "Get All Files"}
    remote isolated function getAllFiles(@display {label: "Filter String"} string? filterString = (), 
                                        @display {label: "Order By"} string? orderBy = ()) 
                                returns @tainted @display {label: "File Stream"} stream<File>|error {
        ListFilesOptional optional = {
            pageSize : 1000,
            supportsAllDrives : true,
            includeItemsFromAllDrives : true
        };
        if (filterString is string) {
            optional.q = filterString;
        }
        if (orderBy is string) {
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieves files by name.
    # 
    # + fileName - Name of the file to search (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, stream of files `stream<File>`. Else an `error`
    @display {label: "Get Files By Name"}
    remote isolated function getFilesByName(@display {label: "File Name"} string fileName, 
                                   @display {label: "Order By"} string? orderBy = ())    
                                   returns @tainted @display {label: "File Stream"} stream<File>|error {
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

    # Retrieves all Google spreadsheets.
    # 
    # + return - If successful, stream of files `stream<File>`. Else an `error`
    @display {label: "Get All Spreadsheets"}
    remote isolated function getAllSpreadsheets() returns @tainted @display {label: "File Stream"} stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + SHEETS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        return getFiles(self.httpClient, optional);
    }

    # Retrieves Google spreadsheets by name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, stream of files `stream<File>`. Else an `error`
    @display {label: "Get Spreadsheets"}
    remote isolated function getSpreadsheetsByName(@display {label: "File Name"} string fileName, 
                                          @display {label: "Order By"} string? orderBy = ()) 
                                          returns @tainted @display {label: "File Stream"} stream<File>|error {
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

    # Retrieves Google documents by name
    # 
    # + fileName - Name of the file to be searched (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, stream of files `stream<File>`. Else an `error`
    @display {label: "Get Documents"}
    remote isolated function getDocumentsByName(@display {label: "File Name"} string fileName, 
                                       @display {label: "Order By"} string? orderBy = ()) 
                                       returns @tainted @display {label: "File Stream"} stream<File>|error {
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

    # Retrieves Google forms by name.
    # 
    # + fileName - Name of the file to be searched (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, stream of files `stream<File>`. Else an `error`
    @display {label: "Get Forms"}
    remote isolated function getFormsByName(@display {label: "File Name"} string fileName, 
                                   @display {label: "Order By"} string? orderBy = ()) 
                                   returns @tainted @display {label: "File Stream"} stream<File>|error {
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

    # Retrieves Google slides by name.
    # 
    # + fileName - Name of the file to be searched (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, stream of files `stream<File>`. Else an `error`
    @display {label: "Get Slides"}
    remote isolated function getSlidesByName(@display {label: "File Name"} string fileName, 
                                    @display {label: "Order By"} string? orderBy = ()) 
                                    returns @tainted @display {label: "File Stream"} stream<File>|error {
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

    # Retrieves folders by name.
    # 
    # + folderName - Name of the folder to be searched (Partial search)
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'.  
    # + return - If successful, stream of files `stream<File>`. Else an `error`
    @display {label: "Get Folders"}
    remote isolated function getFoldersByName(@display {label: "Folder Name"} string folderName, 
                                     @display {label: "Order By"} string? orderBy = ()) 
                                     returns @tainted @display {label: "File Stream"} stream<File>|error {
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

    # Deletes file using the file ID.
    # 
    # + fileId - ID of the file to delete
    # + return - If successful, `boolean` as true. Else an `error`
    @display {label: "Delete File By ID"}
    remote isolated function deleteFile(@display {label: "File ID"} string fileId) 
                               returns @tainted @display {label: "Result"} boolean|error {
        DeleteFileOptional deleteOptional = {supportsAllDrives : true};
        return deleteFileById(self.httpClient, fileId, deleteOptional);
    }

    # Copies file using the file ID.
    # 
    # + fileId - ID of the file to be copied
    # + destinationFolderId - Folder ID of the destination
    # + newFileName - Name of the New file
    # + return - If successful, `File`. Else an `error`
    @display {label: "Copy File"}
    remote isolated function copyFile(@display {label: "File ID"} string fileId, 
                             @display {label: "Destination Folder ID"} string? destinationFolderId = (), 
                             @display {label: "New File Name"} string? newFileName = ()) 
                             returns @tainted File|error {
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

    # Moves file using the file ID.
    # 
    # + fileId - ID of the file to be moved
    # + destinationFolderId - Folder ID of the destination
    # + return - If successful, `File`. Else an `error`
    @display {label: "Move File"} 
    remote isolated function moveFile(@display {label: "File ID"} string fileId, 
                             @display {label: "Destination Folder ID"} string destinationFolderId) 
                             returns @tainted File|error {
        UpdateFileMetadataOptional optionalsFileMetadata = {
            addParents : destinationFolderId
        };
        return updateFileById(self.httpClient, fileId, optional = optionalsFileMetadata);
    }

    # Renames a file.
    # 
    # + fileId - File ID that need to be renamed
    # + newFileName - New file name that should be renamed to
    # + return - If successful, `File`. Else an `error`
    @display {label: "Rename File"} 
    remote isolated function renameFile(@display {label: "File ID"} string fileId, 
                               @display {label: "New File Name"} string newFileName) 
                               returns @tainted File|error {
        FileMetadata fileResource = {name : newFileName};
        return updateFileById(self.httpClient, fileId, fileResource);
    }

    # Updates file metadata using the file ID.
    # 
    # + fileId - ID of the file to be updated
    # + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
    # + fileMetadata - 'FileMetadata' can added as a payload to change metadata
    # + return - If successful, `File`. Else an `error`
    @display {label: "Update File Metadata By ID"}
    remote isolated function updateFileMetadataById(@display {label: "File ID"} string fileId, 
                                                    @display {label: "File Resource"} 
                                                    FileMetadata? fileMetadata = (), 
                                                    @display {label: "Optional Parameters"} 
                                                    UpdateFileMetadataOptional? optional = ()) 
                                                    returns @tainted File|error {
        return updateFileById(self.httpClient, fileId, fileMetadata, optional);
    }

    # Creates new file.
    # 
    # + fileName - Name of the new file to be created
    # + mime - Type of file that is going to create. refer https://developers.google.com/drive/api/v3/mime-types
    #          You need to only specify the last word in the MIME type.
    #          For an example, If you want to create a Google document.. The value for this parameter should be
    #          "document" .. Google sheets -> "spreadsheet" etc
    # + folderId - ID of the parent folder that the new file wants to get created
    # + return - If successful, `File`. Else an `error`
    @display {label: "Create File"} 
    remote isolated function createFile(@display {label: "File Name"} string fileName, 
                               @display {label: "Mime Type"} MimeTypes? mime = (), 
                               @display {label: "Folder ID"} string? folderId = ()) 
                               returns @tainted File|error {
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

    # Creates new folder.
    # 
    # + folderName - Name of the new folder to be created
    # + parentFolderId - ID of the parent folder
    # + return - If successful, `File`. Else an `error`
    @display {label: "Create Folder"} 
    remote isolated function createFolder(@display {label: "Folder Name"} string folderName, 
                                 @display {label: "Parent Folder ID"} string? parentFolderId = ()) 
                                 returns @tainted File|error {
        File fileData = {name : folderName, mimeType : MIME_PREFIX + FOLDER};
        CreateFileOptional optional = {supportsAllDrives : true};
        if (parentFolderId is string){
            fileData.parents = [parentFolderId];
        }
        return createMetaDataFile(self.httpClient, fileData, optional);
    }

    # Uploads new file.
    # 
    # + localPath - Path to the file object to be uploaded
    # + fileName - File name for the uploading file (optional). It will take the base name, if not provided
    # + parentFolderId - Parent folder ID (optional). It will be uploaded to the root, if not provided
    # + return - If successful, `File`. Else an `error`
    @display {label: "Upload File"} 
    remote isolated function uploadFile(@display {label: "Local Path"} string localPath, 
                               @display {label: "File Name"} string? fileName = (), 
                               @display {label: "Parent Folder ID"} string? parentFolderId = ()) 
                               returns @tainted File|error {
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
    
    # Uploads new file using a Byte array.
    # 
    # + byteArray - Byte array that represents the file object
    # + fileName - File name for the uploading file (optional). It will take the base name, if not provided
    # + parentFolderId - Parent folder ID (optional). It will be uploaded to the root, if not provided
    # + return - If successful, `File`. Else an `error`
    @display {label: "Upload File Using Byte Array"} 
    remote isolated function uploadFileUsingByteArray(@display {label: "Byte Array"} byte[] byteArray, 
                                             @display {label: "File name"} string fileName, 
                                             @display {label: "Parent Folder ID"} 
                                             string? parentFolderId = ()) 
                                             returns @tainted File|error {
        File fileMetadata = {name : fileName};
        UpdateFileMetadataOptional optional = {};
        if (parentFolderId is string){
            optional.addParents = parentFolderId;
        }
        return uploadFileUsingByteArray(self.httpClient, byteArray, fileMetadata, optional);
    }

    # Gets the starting pageToken for listing future changes.
    #
    # + return - If successful, returns a `string`; otherwise, returns an `error`
    @display {label: "Get StartPage Token"}
    remote isolated function getStartPageToken() returns string|error {
        string path = prepareUrl([DRIVE_PATH, CHANGES, START_PAGE_TOKEN]) +
                QUESTION_MARK + SUPPORTS_ALL_DRIVES + EQUAL + TRUE;

        json resp = check sendRequest(self.httpClient, path);
        json|error token = resp.startPageToken;

        return token is json ? token.toString()
            : error("startPageToken not found in response");
    }

    # Lists the changes for a user or a shared drive.
    #
    # + pageToken - The token returned from the previous request
    # + optional - A `ListChangesOptional` record used to add query parameters to the request
    # + return - If successful, returns a stream of changes `stream<Change>`; otherwise, returns an `error`
    @display {label: "List Changes"}
    remote isolated function listChanges(@display {label: "Page Token"} string pageToken,
            @display {label: "Optional Params"} ListChangesOptional? optional = ())
        returns @display {label: "Change Stream"} stream<Change>|error {
        Change[] changes = [];
        string? nextPage = pageToken;
        while nextPage is string {
            json raw = check sendRequest(self.httpClient,
                    prepareUrlWithChangesOptional(nextPage, optional));
            ChangeList page = check raw.cloneWithType(ChangeList);
            changes.push(...page.changes);
            nextPage = page.nextPageToken;
        }
        return changes.toStream();
    }
}
