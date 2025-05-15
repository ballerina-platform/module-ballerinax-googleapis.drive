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
// Access token support
//configurable string accessToken = os:getEnv("ACCESS_TOKEN");

configurable string fileName = "FILE_NAME";
configurable string folderName = "FOLDER_NAME";
configurable string docFileId = "DOCUMENT_FILE_ID";
const string localFilePath = "./tests/resources/bar.jpeg";

// Access token support
// Configuration config = {
//     clientConfig: {
//         token: accessToken
//     }
// };

ConnectionConfig config = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: REFRESH_URL,
        refreshToken: refreshToken
    }
};

Client driveClient = check new (config);

string fileId = EMPTY_STRING;
string parentFolderId = EMPTY_STRING;
string channelId = EMPTY_STRING;
string resourceId = EMPTY_STRING;

###################
# Get File By Id
# ################

@test:Config {
    dependsOn: [testCreateFile]
}
function testGetFileById() {
    log:printInfo("Gdrive Client -> testGetFileById()");
    File|error response = driveClient->getFile(fileId);
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response.toString());
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

#########################
# Get File Content By Id
# #######################

@test:Config {
    dependsOn: [testCreateFile]
}
function testGetFileContentById() {
    log:printInfo("Gdrive Client -> testGetFileContentById()");
    FileContent|error response = driveClient->getFileContent(fileId);
    if (response is FileContent) {
        log:printInfo(response.toString());
    } 
    else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

#######################
# Delete File by ID
# #####################

// @test:AfterSuite {}
function testDeleteFileById() {
    log:printInfo("Gdrive Client -> testDeleteFileById()");
    boolean|error response = driveClient->deleteFile(fileId);
    if (response is boolean) {
        log:printInfo("File Deleted");
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
function testCopyFile() {
    log:printInfo("Gdrive Client -> testCopyFile()");
    string sourceFileId = fileId;
    string destinationFolderId = parentFolderId;
    string newFileName = "ballerina_temp_file_copy";
    File|error response = driveClient->copyFile(sourceFileId, destinationFolderId, newFileName);
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response?.id.toString());
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

############
# Move File
# ##########

@test:Config {
    dependsOn: [testCreateFile]
}
function testMoveFile(){
    log:printInfo("Gdrive Client -> testMoveFile()");
    string sourceFileId = fileId;
    string destinationFolderId = parentFolderId;
    File|error response = driveClient->moveFile(sourceFileId, destinationFolderId);
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response?.id.toString());
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

############################
# Rename file
# ##########################

@test:Config {
    dependsOn: [testCreateFile]
}
function testRenameFile() {
    log:printInfo("Gdrive Client -> testRenameFile()");
    string newFileName = fileName+"_renamed";
    File|error response = driveClient->renameFile(fileId, newFileName);
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response?.id.toString());
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

############################
# Update Metadata in a file
# ##########################

@test:Config {
    dependsOn: [testCreateFile]
}
function testUpdateFile() {
    log:printInfo("Gdrive Client -> testUpdateFile()");
    UpdateFileMetadataOptional optionalsFileMetadata = {
        addParents : parentFolderId
    };
    FileMetadata payloadFileMetadata = {
        name : fileName,
        mimeType : "application/vnd.google-apps.document",
        description : "A short description of the file"
    };
    File|error response = driveClient->updateFileMetadataById(fileId, payloadFileMetadata, optionalsFileMetadata);
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response?.id.toString());
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

################
# Create folder
# #############

@test:Config {}
function testCreateFolder() {
    log:printInfo("Gdrive Client -> testCreateFolder()");
    File|error response = driveClient->createFolder(folderName);
    //File|error response = driveClient->createFolder(folderName, "<PARENT_FOLDER_ID>");
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response?.id.toString());
        //Set variable fileId for other unit tests
        parentFolderId = <@untainted> response?.id.toString();
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

##############
# Create file 
# ############

@test:Config {
    dependsOn: [testCreateFolder]
}
function testCreateFile() {
    log:printInfo("Gdrive Client -> testCreateFile()");
    File|error response = driveClient->createFile(fileName);
    //File|error response = driveClient->createFile(fileName, DOCUMENT);
    //File|error response = driveClient->createFile(fileName, DOCUMENT, parentFolderId);
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response?.id.toString());
        //Set variable fileId for other unit tests
        fileId = <@untainted> response?.id.toString();
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

#######################################
# Search files by name (Partial search)
# #####################################

@test:Config {}
function testGetFilesByName() {
    log:printInfo("Gdrive Client -> testGetFilesByName()");
    stream<File>|error response = driveClient->getFilesByName("ballerina");
    // stream<File>|error response = driveClient->getFilesByName("ballerina", "createdTime");
    if (response is stream<File>){
        response.forEach(isolated function (File file) {
            test:assertNotEquals(file?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

##########################################
# Search folders by name (Partial search)
# ########################################

@test:Config {}
function testGetFoldersByName() {
    log:printInfo("Gdrive Client -> testGetFoldersByName()");
    stream<File>|error response = driveClient->getFoldersByName("ballerina");
    // stream<File>|error response = driveClient->getFoldersByName("ballerina", "createdTime");
    if (response is stream<File>){
        response.forEach(isolated function (File file) {
            test:assertNotEquals(file?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

###################
# Get all files
# #################

@test:Config {}
function testAllGetFiles() { 
    log:printInfo("Gdrive Client -> testAllGetFiles()");
    stream<File>|error response = driveClient->getAllFiles("not name contains 'hello'");
    // stream<File>|error response = driveClient->getAllFiles();
    if (response is stream<File>){
        response.forEach(isolated function (File file) {
            test:assertNotEquals(file?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

#############################
# Get All Google spreadsheets 
# ###########################

@test:Config {}
function testGetAllSpreadsheets() {
    log:printInfo("Gdrive Client -> testGetAllSpreadsheets()");
    stream<File>|error response = driveClient->getAllSpreadsheets();
    if (response is stream<File>){
        response.forEach(isolated function (File file) {
            test:assertNotEquals(file?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

######################################################
# Search Google spreadsheets by name (Partial search)
# ####################################################

@test:Config {}
function testGetSpreadsheetsByName() {
    log:printInfo("Gdrive Client -> testGetSpreadsheetsByName()");
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina");
    // stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina","createdTime");
    if (response is stream<File>){
        response.forEach(isolated function (File file) {
            test:assertNotEquals(file?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

###################################################
# Search Google documents by name (Partial search)
# ################################################

@test:Config {}
function testGetDocumentsByName() {
    log:printInfo("Gdrive Client -> testGetDocumentsByName()");
    stream<File>|error response = driveClient->getDocumentsByName("ballerina");
    // stream<File>|error response = driveClient->getDocumentsByName("ballerina", "createdTime");
    if (response is stream<File>){
        response.forEach(isolated function (File file) {
            test:assertNotEquals(file?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

##############################################
# Search Google forms by name (Partial search)
# ############################################

@test:Config {}
function testGetFormsByName() {
    log:printInfo("Gdrive Client -> testGetFormsByName()");
    stream<File>|error response = driveClient->getFormsByName("ballerina");
    // stream<File>|error response = driveClient->getFormsByName("ballerina", "createdTime");
    if (response is stream<File>){
        response.forEach(isolated function (File file) {
            test:assertNotEquals(file?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

##############################################
# Search Google slides by name (Partial search)
# ############################################

@test:Config {}
function testGetSlidesByName() {
    log:printInfo("Gdrive Client -> testGetSlidesByName()");
    stream<File>|error response = driveClient->getSlidesByName("ballerina");
    // stream<File>|error response = driveClient->getSlidesByName("ballerina", "createdTime");
    if (response is stream<File>){
        response.forEach(isolated function (File file) {
            test:assertNotEquals(file?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

##############
# Upload File
# ############

@test:Config {
    dependsOn: [testCreateFolder]
}
function testUploadFile() {
    log:printInfo("Gdrive Client -> testUploadFile()");
    File|error response = driveClient->uploadFile(localFilePath);
    // Assertions 
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

################
# Download File
# ##############

@test:Config {
    dependsOn: [testCreateFile]
}
function testDownloadFileById() {
    log:printInfo("Gdrive Client -> testDownloadFileById()");
    string downloadFileId = fileId;
    string|error response = driveClient->downloadFile(downloadFileId);
    if(response is string){
        test:assertNotEquals(response, EMPTY_STRING, msg = "Expect download URL link");
        log:printInfo(response);
    } else {
        test:assertFail(response.message());
    }
}

###############################
# Upload File using Byte Array
# #############################

@test:Config {
    dependsOn: [testCreateFolder]
}
function testUploadFileUsingByteArray() {
    log:printInfo("Gdrive Client -> testUploadFileUsingByteArray()");
    byte[] byteArray = [116,101,115,116,45,115,116,114,105,110,103];
    File|error response = driveClient->uploadFileUsingByteArray(byteArray, fileName);
    // Assertions 
    if(response is File){
        string id = response?.id.toString();
        log:printInfo(id);
        test:assertNotEquals(id, EMPTY_STRING, msg = "Expect File id");
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

@test:Config {
    dependsOn: [testCreateFile]
}
function testExportFile() returns error? {
    log:printInfo("Gdrive Client -> testExportFile()");
    string mimeType = "text/markdown";
    FileContent content = check driveClient->exportFile(docFileId, mimeType);
    log:printInfo(content.toString().substring(0, 10));
    test:assertNotEquals(content, EMPTY_STRING, msg = "Expect File content");
}

@test:Config {}
function testGetStartPageToken() returns error? {
    log:printInfo("Gdrive Client -> testGetStartPageToken()");
    string response = check driveClient->getStartPageToken();
    test:assertNotEquals(response, EMPTY_STRING, msg = "Expect non-empty start page token");
    log:printInfo("Start page token: " + response);
}

@test:Config {
    dependsOn: [testGetStartPageToken]
}
function testListChanges() returns error? {
    log:printInfo("Gdrive Client -> testListChanges()");
    string tokenResponse = check driveClient->getStartPageToken();
    stream<Change> changesResponse = check driveClient->listChanges(tokenResponse);
    boolean hasChanges = false;
    changesResponse.forEach(function(Change change) {
        hasChanges = true;
        log:printInfo("Unexpected change: " + change.toString());
    });
    test:assertFalse(hasChanges, msg = "Expected no changes, but changes were found");
}
