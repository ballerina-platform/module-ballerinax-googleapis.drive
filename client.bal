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

# Google Drive Client. 
#
# + httpClient - The HTTP Client  
public client class Client {
    public http:Client httpClient;
    Configuration driveConfiguration;

    public function init(Configuration driveConfig) returns error? {    
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
    # + return - If successful, returns `File`. Else returns `error`
    remote function getFile(string fileId) returns @tainted File|error {
        GetFileOptional optional = {supportsAllDrives : true};
        return getFileById(self.httpClient , fileId, optional);
    }

    # Download file using the fileID.
    # 
    # + fileId - ID of the file to retreive
    # + return - If successful, returns `string`. Else returns `error`
    remote function downloadFile(string fileId) returns @tainted string|error {
        GetFileOptional optional = {supportsAllDrives : true, fields : WEB_CONTENT_LINK};
        File fileResponse = check getFileById(self.httpClient , fileId, optional);
        return fileResponse?.webContentLink.toString();
    }

    # Retrieve files.
    # 
    # + optional - 'ListFilesOptional' used to add query parameters to the request
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function getFiles(ListFilesOptional? optional = ()) returns @tainted stream<File>|error {
        return getFiles(self.httpClient, optional);
    }

    # Filter and retreive files using filter string
    # 
    # + filterString - Query used to find what you need. Read documentation for query string patterns.
    # + noOfFiles - Number of files to retreive 
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function filterFiles(string filterString, int? noOfFiles = (), string? orderBy = ()) returns @tainted 
                                stream<File>|error {
        ListFilesOptional optional = {};
        optional.q = filterString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (noOfFiles is int){
            optional.pageSize = noOfFiles;
        }
        if (orderBy is string){
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieve files by Name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + noOfFiles - Number of files to retreive 
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function getFilesByName(string fileName, int? noOfFiles = (), string? orderBy = ()) 
                                    returns @tainted stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND + 
                                SPACE + TRASH_FALSE;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (noOfFiles is int){
            optional.pageSize = noOfFiles;
        }
        if (orderBy is string){
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    } 

    # Retrieve all Google spreadsheets
    # 
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function getAllSpreadsheets() returns @tainted stream<File>|error {
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
    # + noOfFiles - Number of files to retreive 
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function getSpreadsheetsByName(string fileName, int? noOfFiles = (), string? orderBy = ()) 
                                            returns @tainted stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND + 
                                SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + SHEETS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (noOfFiles is int){
            optional.pageSize = noOfFiles;
        }
        if (orderBy is string){
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    } 

    # Retrieve Google documents by Name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + noOfFiles - Number of files to retreive 
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function getDocumentsByName(string fileName, int? noOfFiles = (), string? orderBy = ()) 
                                        returns @tainted stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND + 
                                SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + DOCS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (noOfFiles is int){
            optional.pageSize = noOfFiles;
        }
        if (orderBy is string){
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieve Google forms by Name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + noOfFiles - Number of files to retreive 
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function getFormsByName(string fileName, int? noOfFiles = (), string? orderBy = ()) returns @tainted stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND + 
                                SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + FORMS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (noOfFiles is int){
            optional.pageSize = noOfFiles;
        }
        if (orderBy is string){
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieve Google slides by Name
    # 
    # + fileName - Name of the file to search (Partial search)
    # + noOfFiles - Number of files to retreive 
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function getSlidesByName(string fileName, int? noOfFiles = (), string? orderBy = ()) returns @tainted stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + fileName + SINGLE_QUOTE + SPACE + AND + 
                                SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + SLIDES;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (noOfFiles is int){
            optional.pageSize = noOfFiles;
        }
        if (orderBy is string){
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Retrieve folders by Name
    # 
    # + folderName - Name of the folder to search (Partial search)
    # + noOfFolders - Number of folders to retreive 
    # + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 'modifiedByMeTime', 
    #             'modifiedTime', 'name', 'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', 
    #              and 'viewedByMeTime'.  
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function getFoldersByName(string folderName, int? noOfFolders = (), string? orderBy = ()) 
                                        returns @tainted stream<File>|error {
        ListFilesOptional optional = {};
        string searchString = NAME + SPACE + CONTAINS + SPACE + SINGLE_QUOTE + folderName + SINGLE_QUOTE + SPACE + AND + 
                                SPACE + TRASH_FALSE + SPACE + AND + SPACE + MIME_TYPE + EQUAL + FOLDERS;
        optional.q = searchString;
        optional.supportsAllDrives = true;
        optional.includeItemsFromAllDrives = true;
        if (noOfFolders is int){
            optional.pageSize = noOfFolders;
        }
        if (orderBy is string){
            optional.orderBy = orderBy;
        }
        return getFiles(self.httpClient, optional);
    }

    # Delete file using the fileID.
    # 
    # + fileId - ID of the file to delete
    # + return - If successful, returns `boolean` as true. Else returns `error`
    remote function deleteFile(string fileId) returns @tainted boolean|error {
        DeleteFileOptional deleteOptional = {supportsAllDrives : true};
        return deleteFileById(self.httpClient, fileId, deleteOptional);
    }

    # Copy file using the fileID.
    # 
    # + fileId - ID of the file to copy
    # + destinationFolderId - Folder ID of the destination
    # + newFileName - Name of the New file
    # + return - If successful, returns `File`. Else returns `error`
    remote function copyFile(string fileId, string? destinationFolderId = (), string? newFileName = ()) returns @tainted 
                                File|error {
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
    remote function moveFile(string fileId, string destinationFolderId) returns @tainted File|error {
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
    remote function renameFile(string fileId, string newFileName) returns @tainted File|error {
        File fileResource = {name : newFileName};
        return updateFileById(self.httpClient, fileId, fileResource);
    }

    # Update file metadata using the fileID.
    # 
    # + fileId - ID of the file to be updated
    # + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
    # + fileResource - 'File' can added as a payload to change metadata
    # + return - If successful, returnsoptionalsFileMetadata `File`. Else returns `error`
    remote function updateFileMetadataById(string fileId, File? fileResource = (), 
                                            UpdateFileMetadataOptional? optional = ()) returns @tainted File|error {
        return updateFileById(self.httpClient, fileId, fileResource, optional);
    }

    # Create new file.
    # 
    # + optional - 'CreateFileOptional' used to add query parameters to the request
    # + fileData - 'File' Metadata is send to in the payload 
    # + return - If successful, returns `File`. Else returns `error`
    remote function createMetaDataFile(CreateFileOptional? optional = (), File? fileData = ()) 
                                        returns @tainted File|error {
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
    remote function createFile(string fileName, string? mime = (), string? folderId = ()) returns @tainted File|error {
        CreateFileOptional optional = {supportsAllDrives : true};
        File fileData = {name : fileName};
        if (mime is string){
            fileData.mimeType = MIME_PREFIX + mime;
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
    remote function createFolder(string folderName, string? parentFolderId = ()) returns @tainted File|error {
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
    remote function uploadFile(string localPath, string? fileName = (), string? parentFolderId = ()) 
                                returns @tainted File|error {
        string originalFileName = check file:basename(localPath);
        File fileMetadata = {name : originalFileName};
        if (fileName is string){
            fileMetadata.name = fileName;
        }
        UpdateFileMetadataOptional optional = {};
        if (parentFolderId is string){
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
    remote function uploadFileUsingByteArray(byte[] byteArray, string fileName, string? parentFolderId = ()) 
                                                returns @tainted File|error {
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
    remote function getAbout(string? fields) returns @tainted About|error {
        return getDriveInfo(self.httpClient , fields);
    }
} 
