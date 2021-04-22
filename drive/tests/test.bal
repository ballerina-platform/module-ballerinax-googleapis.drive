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

const string fileName = "ballerina_temp_file"; 
const string folderName = "ballerina_temp_folder";
const string localFilePath = "./tests/resources/bar.jpeg";

// Access token support
// Configuration config = {
//     clientConfig: {
//         token: accessToken
//     }
// };

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
string channelId = EMPTY_STRING;
string resourceId = EMPTY_STRING;

########################
# Get Drive Information
# ######################

@test:Config {}
function testGetDriveInformation() {    
    log:printInfo("Gdrive Client -> testdriveGetAbout()");
    About|error response = driveClient->getAbout("user");
    if (response is About){
        test:assertNotEquals(response?.user, EMPTY_STRING, msg = "Expect Drive User");
        log:printInfo(response?.user.toString());
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
    log:printInfo("Gdrive Client -> testGetFileById()");
    File|error response = driveClient->getFile(fileId);
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response.toString());
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
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
    log:printInfo("Gdrive Client -> testMoveFile()");
    string sourceFileId = fileId;
    string destinationFolderId = parentFolderId;
    File|error response = driveClient->moveFile(sourceFileId, destinationFolderId);
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response?.id.toString());
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
    log:printInfo("Gdrive Client -> testRenameFile()");
    string newFileName = fileName+"_renamed";
    File|error response = driveClient->renameFile(fileId, newFileName);
    //Assertions
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response?.id.toString());
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
function testUpdateFile() {
    log:printInfo("Gdrive Client -> testUpdateFile()");
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
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response?.id.toString());
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
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

###################
# Get files
# #################

@test:Config {}
function testGetFiles() { 
    log:printInfo("Gdrive Client -> testGetFiles()");
    ListFilesOptional optionalSearch = {
        orderBy : "createdTime"
    };
    stream<File>|error response = driveClient->getFiles(optionalSearch);
    if (response is stream<File>){
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
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
    log:printInfo("Gdrive Client -> testFilterFiles()");
    string filterString = "name contains 'hello'";
    stream<File>|error response = driveClient->filterFiles(filterString);
    if (response is stream<File>){
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
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
    log:printInfo("Gdrive Client -> testGetFilesByName()");
    stream<File>|error response = driveClient->getFilesByName("ballerina");
    // stream<File>|error response = driveClient->getFilesByName("ballerina", "createdTime");
    if (response is stream<File>){
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
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
    log:printInfo("Gdrive Client -> testGetFoldersByName()");
    stream<File>|error response = driveClient->getFoldersByName("ballerina");
    // stream<File>|error response = driveClient->getFoldersByName("ballerina", "createdTime");
    if (response is stream<File>){
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
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
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
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
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
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
function testGetSpreadsheetsByName() {
    log:printInfo("Gdrive Client -> testGetSpreadsheetsByName()");
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina");
    // stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina","createdTime");
    if (response is stream<File>){
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
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
function testGetDocumentsByName() {
    log:printInfo("Gdrive Client -> testGetDocumentsByName()");
    stream<File>|error response = driveClient->getDocumentsByName("ballerina");
    // stream<File>|error response = driveClient->getDocumentsByName("ballerina", "createdTime");
    if (response is stream<File>){
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
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
function testGetFormsByName() {
    log:printInfo("Gdrive Client -> testGetFormsByName()");
    stream<File>|error response = driveClient->getFormsByName("ballerina");
    // stream<File>|error response = driveClient->getFormsByName("ballerina", "createdTime");
    if (response is stream<File>){
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
        });
    } else {
        test:assertFail(response.message());
        log:printError(response.message());
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
        error? e = response.forEach(isolated function (File response) {
            test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
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
function testUploadFile() {
    log:printInfo("Gdrive Client -> testUploadFile()");
    File|error response = driveClient->uploadFile(localFilePath);
    // Assertions 
    if(response is File){
        test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expect File id");
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
        test:assertFail(response.message());
        log:printError(response.message());
    }
}

##############################################
# Subcribe for changes - Single File Resource
# ############################################

@test:Config { enable: false }
function testWatchFilesById() {
    string fileIdToBeWatched = fileId;
    string address = "<REGISTERED_DOMAIN_ADDRESS>";
    WatchResponse|error response = driveClient->watchFilesById(fileIdToBeWatched, address);
    if(response is WatchResponse){
        channelId = <@untainted> response?.id.toString();
        resourceId = <@untainted> response?.resourceId.toString();
        test:assertNotEquals(channelId, EMPTY_STRING, msg = "Expect File id");
        log:printInfo(response.toString());
    } else {
        log:printInfo(response.toString());
    }
}

########################################
# Subcribe for all changes in resources
# ######################################

@test:Config { enable: false }
function testWatchAllFiles() {
    string address = "<REGISTERED_DOMAIN_ADDRESS>";
    WatchResponse|error response = driveClient->watchFiles(address);
    if(response is WatchResponse){
        channelId = <@untainted> response?.id.toString();
        resourceId = <@untainted> response?.resourceId.toString();
        test:assertNotEquals(channelId, EMPTY_STRING, msg = "Expect channelId");
        log:printInfo(response.toString());
    } else {
        test:assertFail(response.message());
        log:printInfo(response.message());
    }
}

##########################
# Stop watching resources 
# ########################

@test:Config {
    enable: false,
    dependsOn: [testWatchFilesById, testWatchAllFiles]
}
function testStopWatching() {
    boolean|error response = driveClient->watchStop(channelId, resourceId);
    if (response is boolean) {
        log:printInfo("Watch channel stopped");
        test:assertTrue(response, msg = "Expects true on success");
    } else {
        log:printError(response.message());
        test:assertFail(response.message());
    }
}

##########################
# List changes  
# ########################

@test:Config {
    enable: false,
    dependsOn: [testWatchFilesById, testWatchAllFiles]
}
function testListChanges() {
    string pageToken = "<PAGE_TOKEN>";
    ChangesListResponse|error response = driveClient->listChanges(pageToken);
    if (response is ChangesListResponse) {
        test:assertEquals(response?.kind, "drive#changeList", 
                            msg = "Expects kind as drive#changeList in ChangesListResponse");
        log:printInfo(response.toString());
    } else {
        log:printInfo(response.message());
        test:assertFail(response.message());
    }
}
