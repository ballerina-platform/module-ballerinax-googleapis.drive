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

import ballerina/log;
import ballerina/os;
import ballerina/test;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");

const string fileName = "ballerina_temp_file"; 
const string folderName = "ballerina_temp_folder";
const string filePath = "./tests/resources/bar.jpeg";

Configuration config = {
    clientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: REFRESH_URL,
        refreshToken: refreshToken
    }
};

Client driveClient = check new (config);

string fileId = EMPTY_STRING;
string parentFolder = EMPTY_STRING;

########################
# Get Drive Information
# ######################

@test:Config {}
function testdriveGetAbout() {    
    log:print("Gdrive Client -> testdriveGetAbout()");
    About|error response = driveClient->getAbout("user");
    if (response is About){
        test:assertNotEquals(response?.user, "", msg = "Expect Drive User");
        log:print(response?.user.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

###################
# Get File By Id
# ################

@test:Config {
    dependsOn: [testCreateFile]
}
function testGetFileById() {
    log:print("Gdrive Client -> testGetFileById()");
    File|error response = driveClient->getFileById(fileId);
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

################################
# Get File By ID with optionals
# #############################

GetFileOptional optional = {
    acknowledgeAbuse: false,
    supportsAllDrives : false
};

@test:Config {
    dependsOn: [testCreateFile]
}
function testGetFileByIdwithOptionalParameters() {
    log:print("Gdrive Client -> testGetFileByIdwithOptionalParameters()");
    File | error response = driveClient->getFileById(fileId, optional);
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

#######################
# Delete File by ID
# #####################

@test:Config {
    dependsOn: [testCopyFile, testGetFileByIdwithOptionalParameters]
}
function testDeleteFileById(){
    log:print("Gdrive Client -> testDeleteFileById()");
    DeleteFileOptional deleteOptional = {
        supportsAllDrives : false
    };
    boolean|error response = driveClient->deleteFileById(fileId, deleteOptional);
    if (response is boolean) {
        log:print("File Deleted");
        test:assertTrue(response, msg = "Expects true on success");
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

############
# Copy File
# ##########

@test:Config {
    dependsOn: [testCreateFile]
}
function testCopyFile(){
    log:print("Gdrive Client -> testCopyFile()");
    CopyFileOptional optionalsCopyFile = {"includePermissionsForView" : "published"};
    File payloadCopyFile = {
        name : fileName //New name
    };
    File|error response = driveClient->copyFile(fileId ,optionalsCopyFile ,payloadCopyFile );
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

############################
# Update Metadata in a file
# ##########################

@test:Config {
    dependsOn: [testCreateFile]
}
function testUpdateFiles() {
    log:print("Gdrive Client -> testUpdateFiles()");
    UpdateFileMetadataOptional optionalsFileMetadata = {
        addParents : parentFolder
    };
    File payloadFileMetadata = {
        name : fileName
    };
    File|error response = driveClient->updateFileMetadataById(fileId, optionalsFileMetadata, payloadFileMetadata);
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

#########################
# Create Metadata file
# ######################

@test:Config {
    dependsOn: [testCreateFolder]
}
function testCreateFile() {
    log:print("Gdrive Client -> testCreateFile()");
    CreateFileOptional optionalsCreateFile = {
        ignoreDefaultVisibility : false
    };
    File payloadCreateFile = {
        mimeType : "application/vnd.google-apps.document",
        name : fileName
        //parents : [parentFolder]
    };
    File|error response = driveClient->createMetaDataFile(optionalsCreateFile, payloadCreateFile);
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
    //Set variable fileId
    fileId = <@untainted> getIdFromFileResponse(response);
}

##############################
# Create Folder with Metadata
# ############################

@test:Config {}
function testCreateFolder() {
    log:print("Gdrive Client -> testCreateFolder()");
    CreateFileOptional optionalsCreateFolder = {
        ignoreDefaultVisibility : false
    };
    File payloadCreateFolder = {
        mimeType : "application/vnd.google-apps.folder",
        name : folderName
    };
    File|error response = driveClient->createMetaDataFile(optionalsCreateFolder, payloadCreateFolder);
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
    parentFolder = <@untainted> getIdFromFileResponse(response);
}

###################
# Get files
# #################

@test:Config {}
function testGetFiles() {
    log:print("Gdrive Client -> testGetFiles()");
    ListFilesOptional optionalSearch = {
        pageSize : 3
    };
    stream<File>|error response = driveClient->getFiles(optionalSearch);
    if (response is stream<File>){
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, "", msg = "Expect File id");
            log:print(response?.id.toString());
        });
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

##############
# Upload File
# ############

@test:Config {
    dependsOn: [testCreateFolder]
}
function testNewUpload() {
    log:print("Gdrive Client -> testNewUpload()");
    UpdateFileMetadataOptional optionals = {
        addParents : parentFolder //Parent folderID
    };
    File payload = {
        name : fileName
    };
    File|error response = driveClient->uploadFile(filePath, optionals, payload);
    // Assertions 
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

###############################
# Upload File using Byte Array
# #############################

@test:Config {
    dependsOn: [testCreateFolder]
}
function testNewUploadByteArray() {
    log:print("Gdrive Client -> testNewUploadByteArray()");
    UpdateFileMetadataOptional optionals = {
        addParents : parentFolder //Parent folderID
    };
    File payload = {
        name : fileName
    };
    byte[] byteArray = [116,101,115,116,45,115,116,114,105,110,103];
    File|error response = driveClient->uploadFileUsingByteArray(byteArray, optionals, payload);
    // Assertions 
    if(response is File){
        string id = response?.id.toString();
        log:print(id);
        test:assertNotEquals(id, "", msg = "Expect File id");
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}
