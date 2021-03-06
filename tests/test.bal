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
const string localFilePath = "./tests/resources/bar.jpeg";

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
string parentFolderId = EMPTY_STRING;

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
    File|error response = driveClient->getFile(fileId);
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

################
# Download File
# ##############

@test:Config {
    dependsOn: [testCreateFile]
}
function testDownloadFileById() {
    log:print("Gdrive Client -> testDownloadFileById()");
    string|error response = driveClient->downloadFile(fileId);
    if(response is string){
        test:assertNotEquals(response, "", msg = "Expect download URL link");
        log:print(response);
    } else {
        test:assertFail(response.message());
    }
}

#######################
# Delete File by ID
# #####################

// @test:AfterSuite {}
function testDeleteFileById(){
    log:print("Gdrive Client -> testDeleteFileById()");
    boolean|error response = driveClient->deleteFile(fileId);
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
    string sourceFileId = fileId;
    string destinationFolderId = parentFolderId;
    string newFileName = "ballerina_temp_file_copy";
    File|error response = driveClient->copyFile(sourceFileId, destinationFolderId, newFileName);
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

############
# Move File
# ##########

@test:Config {
    dependsOn: [testCreateFile]
}
function testMoveFile(){
    log:print("Gdrive Client -> testMoveFile()");
    string sourceFileId = fileId;
    string destinationFolderId = parentFolderId;
    File|error response = driveClient->moveFile(sourceFileId, destinationFolderId);
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

############################
# Rename file
# ##########################

@test:Config {
    dependsOn: [testCreateFile]
}
function testRenameFile() {
    log:print("Gdrive Client -> testRenameFile()");
    string newFileName = fileName+"_renamed";
    File|error response = driveClient->renameFile(fileId, newFileName);
    //Assertions
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
        addParents : parentFolderId
    };
    File payloadFileMetadata = {
        name : fileName,
        mimeType : "application/vnd.google-apps.document",
        description : "A short description of the file"
    };
    File|error response = driveClient->updateFileMetadataById(fileId, payloadFileMetadata, optionalsFileMetadata);
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

################
# Create folder
# #############

@test:Config {}
function testCreateFolder() {
    log:print("Gdrive Client -> testCreateFolder()");
    File|error response = driveClient->createFolder(folderName, "1mskwVJ1v02L1u7O8AhPNswVstWjOXctT");
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
        //Set variable fileId for other unit tests
        parentFolderId = response?.id.toString();
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

##############
# Create file 
# ############

@test:Config {
    dependsOn: [testCreateFolder]
}
function testCreateFile() {
    log:print("Gdrive Client -> testCreateFile()");
    File|error response = driveClient->createFile(fileName);
    // File|error response = driveClient->createFile(fileName, "application/vnd.google-apps.document");
    // File|error response = driveClient->createFile(fileName, "application/vnd.google-apps.document", parentFolderId);
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, "", msg = "Expect File id");
        log:print(response?.id.toString());
        //Set variable fileId for other unit tests
        fileId = response?.id.toString();
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

###################
# Get files
# #################

@test:Config {}
function testGetFiles() { 
    log:print("Gdrive Client -> testGetFiles()");
    ListFilesOptional optionalSearch = {
        pageSize : 3,
        orderBy : "createdTime"
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

###################
# Filter files
# #################

@test:Config {}
function testFilterFiles() { 
    log:print("Gdrive Client -> testFilterFiles()");
    string filterString = "name contains 'hello'";
    // stream<File>|error response = driveClient->filterFiles(filterString);
    // stream<File>|error response = driveClient->filterFiles(filterString, 2);
    stream<File>|error response = driveClient->filterFiles(filterString, 4, "createdTime");
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

#######################################
# Search files by name (Partial search)
# #####################################

@test:Config {}
function testGetFilesByName() {
    log:print("Gdrive Client -> testGetFilesByName()");
    // stream<File>|error response = driveClient->getFilesByName("ballerina");
    // stream<File>|error response = driveClient->getFilesByName("ballerina", 2);
    stream<File>|error response = driveClient->getFilesByName("ballerina", 2, "createdTime");
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

##########################################
# Search folders by name (Partial search)
# ########################################

@test:Config {}
function testGetFoldersByName() {
    log:print("Gdrive Client -> testGetFoldersByName()");
    stream<File>|error response = driveClient->getFoldersByName("ballerina");
    // stream<File>|error response = driveClient->getFoldersByName("ballerina", 2);
    // stream<File>|error response = driveClient->getFoldersByName("ballerina", 2, "createdTime");
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


######################################################
# Search Google spreadsheets by name (Partial search)
# ####################################################

@test:Config {}
function testSpreadsheetsByName() {
    log:print("Gdrive Client -> testSpreadsheetsByName()");
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina");
    // stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina", 2);
    // stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina", 2, "createdTime");
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

###################################################
# Search Google documents by name (Partial search)
# ################################################

@test:Config {}
function testDocumentsByName() {
    log:print("Gdrive Client -> testDocumentsByName()");
    stream<File>|error response = driveClient->getDocumentsByName("ballerina");
    // stream<File>|error response = driveClient->getDocumentsByName("ballerina", 2);
    // stream<File>|error response = driveClient->getDocumentsByName("ballerina", 2, "createdTime");
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

##############################################
# Search Google forms by name (Partial search)
# ############################################

@test:Config {}
function testFormsByName() {
    log:print("Gdrive Client -> testFormsByName()");
    stream<File>|error response = driveClient->getFormsByName("ballerina");
    // stream<File>|error response = driveClient->getFormsByName("ballerina", 2);
    // stream<File>|error response = driveClient->getFormsByName("ballerina", 2, "createdTime");
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

##############################################
# Search Google Slides by name (Partial search)
# ############################################

@test:Config {}
function testSlidesByName() {
    log:print("Gdrive Client -> testSlidesByName()");
    stream<File>|error response = driveClient->getSlidesByName("ballerina");
    // stream<File>|error response = driveClient->getSlidesByName("ballerina", 2);
    // stream<File>|error response = driveClient->getSlidesByName("ballerina", 2, "createdTime");
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
    File|error response = driveClient->uploadFile(localFilePath);
    // File|error response = driveClient->uploadFile(localFilePath, fileName);
    // File|error response = driveClient->uploadFile(localFilePath, fileName, parentFolderId);
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
    byte[] byteArray = [116,101,115,116,45,115,116,114,105,110,103];
    File|error response = driveClient->uploadFileUsingByteArray(byteArray, fileName, parentFolderId);
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
