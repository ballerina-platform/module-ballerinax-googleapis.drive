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
    # + optional - 'GetFileOptional' used to add query parameters to the request
    # + return - If successful, returns `File`. Else returns `error`
    remote function getFileById(string fileId, GetFileOptional? optional = ()) returns @tainted File|error {
        return getFileById(self.httpClient , fileId, optional);
    }

    # Retrieve files.
    # 
    # + optional - 'ListFilesOptional' used to add query parameters to the request
    # + return - If successful, returns stream of files `stream<File>`. Else returns `error`
    remote function getFiles(ListFilesOptional? optional = ()) returns @tainted stream<File>|error {
        return getFiles(self.httpClient, optional);
    }

    # Delete file using the fileID.
    # 
    # + fileId - ID of the file to delete
    # + optional - 'DeleteFileOptional' used to add query parameters to the request
    # + return - If successful, returns `boolean` as true. Else returns `error`
    remote function deleteFileById(string fileId, DeleteFileOptional? optional = ()) returns @tainted boolean|error {
        return deleteFileById(self.httpClient, fileId, optional);
    }

    # Copy file using the fileID.
    # 
    # + fileId - ID of the file to copy
    # + optional - 'CopyFileOptional' used to add query parameters to the request
    # + fileResource - 'File' can added as a payload to change metadata
    # + return - If successful, returns `File`. Else returns `error`
    remote function copyFile(string fileId, CopyFileOptional? optional = (), File? fileResource = ()) returns @tainted 
                                File|error {
        return copyFile(self.httpClient, fileId, optional, fileResource);
    }

    # Update file metadata using the fileID.
    # 
    # + fileId - ID of the file to be updated
    # + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
    # + fileResource - 'File' can added as a payload to change metadata
    # + return - If successful, returns `File`. Else returns `error`
    remote function updateFileMetadataById(string fileId, UpdateFileMetadataOptional? optional = (), 
                                            File? fileResource = ()) returns @tainted File|error {
        return updateFileById(self.httpClient, fileId, optional, fileResource);
    }

    # Create new file (with only metadata).
    # 
    # + optional - 'CreateFileOptional' used to add query parameters to the request
    # + fileData - 'File' Metadata is send to in the payload 
    # + return - If successful, returns `File`. Else returns `error`
    remote function createMetaDataFile(CreateFileOptional? optional = (), File? fileData = ()) 
                                       returns @tainted File|error {
        return createMetaDataFile(self.httpClient, optional, fileData);
    }

    # Upload new file.
    # 
    # + filePath - Path to the file object to be uploaded
    # + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
    # + fileMetadata - 'File' Metadata is send to in the payload 
    # + return - If successful, returns `File`. Else returns `error`
    remote function uploadFile(string filePath, UpdateFileMetadataOptional? optional = (), 
                                File? fileMetadata = ()) returns @tainted File|error {
        return uploadFile(self.httpClient, filePath, optional, fileMetadata);
    }

    # Upload new file using a Byte array.
    # 
    # + byteArray - Byte array that represents the file object
    # + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
    # + fileMetadata - 'File' Metadata is send to in the payload 
    # + return - If successful, returns `File`. Else returns `error`
    remote function uploadFileUsingByteArray(byte[] byteArray, UpdateFileMetadataOptional? optional = (), 
                                            File? fileMetadata = ()) returns @tainted File|error {
        return uploadFileUsingByteArray(self.httpClient, byteArray, optional, fileMetadata);
    }

    # Gets information about the user, the user's Drive, and system capabilities.
    # 
    # + fields - The paths of the fields you want included in the response
    # + return - If successful, returns `About`. Else returns `error`
    remote function getAbout(string? fields) returns @tainted About|error {
        return getDriveInfo(self.httpClient , fields);
    }
} 
