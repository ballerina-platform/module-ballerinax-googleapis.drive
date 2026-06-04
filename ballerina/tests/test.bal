// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

// Test resource for upload tests
const string LOCAL_FILE_PATH = "./tests/resources/bar.jpeg";

// IDs captured during test run
string createdFileId = "";
string createdFolderId = "";

// ---------------------------------------------------------------------------
// Client initialisation
// ---------------------------------------------------------------------------

final Client driveClient = check new ({
    auth: {
        clientId,
        clientSecret,
        refreshUrl: REFRESH_URL,
        refreshToken
    }
});

// ---------------------------------------------------------------------------
// Folder & File creation  (anchors for dependent tests)
// ---------------------------------------------------------------------------

@test:Config {}
function testCreateFolder() returns error? {
    log:printInfo("driveClient -> testCreateFolder()");
    File response = check driveClient->createFolder("TestFolder");
    string folderId = response?.id ?: "";
    test:assertNotEquals(folderId, EMPTY_STRING, msg = "Expected a folder ID");
    createdFolderId = folderId;
    log:printInfo("Created folder ID: " + createdFolderId);
}

@test:Config {
    dependsOn: [testCreateFolder]
}
function testCreateFile() returns error? {
    log:printInfo("driveClient -> testCreateFile()");
    File response = check driveClient->createFile("TestFile");
    string fileId = response?.id ?: "";
    test:assertNotEquals(fileId, EMPTY_STRING, msg = "Expected a file ID");
    createdFileId = fileId;
    log:printInfo("Created file ID: " + createdFileId);
}

// ---------------------------------------------------------------------------
// Get / read operations
// ---------------------------------------------------------------------------

@test:Config {
    dependsOn: [testCreateFile]
}
function testGetFileById() returns error? {
    log:printInfo("driveClient -> testGetFileById()");
    File response = check driveClient->getFile(createdFileId);
    test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expected a file ID");
    log:printInfo("File ID: " + response?.id.toString());
}

@test:Config {
    dependsOn: [testCreateFile]
}
function testGetFileContent() returns error? {
    log:printInfo("driveClient -> testGetFileContent()");
    FileContent response = check driveClient->getFileContent(createdFileId);
    test:assertTrue(response.content.length() >= 0, msg = "Expected file content to be retrievable");
    test:assertNotEquals(response.mimeType, EMPTY_STRING, msg = "Expected a MIME type");
    log:printInfo("MIME type: " + response.mimeType);
}

@test:Config {
    dependsOn: [testCreateFile]
}
function testDownloadFile() returns error? {
    log:printInfo("driveClient -> testDownloadFile()");
    string downloadLink = check driveClient->downloadFile(createdFileId);
    test:assertNotEquals(downloadLink, EMPTY_STRING, msg = "Expected a non-empty download link");
    log:printInfo("Download link: " + downloadLink);
}

@test:Config {
    dependsOn: [testCreateFile]
}
function testExportFile() returns error? {
    log:printInfo("driveClient -> testExportFile()");
    FileContent response = check driveClient->exportFile(createdFileId, "text/markdown");
    test:assertTrue(response.content.length() > 0, msg = "Expected non-empty exported content");
    test:assertNotEquals(response.mimeType, EMPTY_STRING, msg = "Expected a MIME type");
    log:printInfo("Exported MIME type: " + response.mimeType);
}

// ---------------------------------------------------------------------------
// List / search operations
// ---------------------------------------------------------------------------

@test:Config {}
function testGetAllFiles() returns error? {
    log:printInfo("driveClient -> testGetAllFiles()");
    stream<File> fileStream = check driveClient->getAllFiles();
    File[] files = from File f in fileStream select f;
    test:assertTrue(files.length() > 0, msg = "Expected at least one file");
    test:assertNotEquals(files[0]?.id, EMPTY_STRING, msg = "Expected a file ID");
}

@test:Config {}
function testGetFilesByName() returns error? {
    log:printInfo("driveClient -> testGetFilesByName()");
    stream<File> fileStream = check driveClient->getFilesByName("TestFile");
    File[] files = from File f in fileStream select f;
    test:assertTrue(files.length() > 0, msg = "Expected at least one matching file");
}

@test:Config {}
function testGetAllSpreadsheets() returns error? {
    log:printInfo("driveClient -> testGetAllSpreadsheets()");
    stream<File> fileStream = check driveClient->getAllSpreadsheets();
    File[] files = from File f in fileStream select f;
    test:assertTrue(files.length() > 0, msg = "Expected at least one spreadsheet");
}

@test:Config {}
function testGetSpreadsheetsByName() returns error? {
    log:printInfo("driveClient -> testGetSpreadsheetsByName()");
    stream<File> fileStream = check driveClient->getSpreadsheetsByName("TestFile");
    File[] files = from File f in fileStream select f;
    test:assertTrue(files.length() >= 0, msg = "Expected spreadsheet search to complete without error");
}

@test:Config {}
function testGetDocumentsByName() returns error? {
    log:printInfo("driveClient -> testGetDocumentsByName()");
    stream<File> fileStream = check driveClient->getDocumentsByName("TestFile");
    File[] files = from File f in fileStream select f;
    test:assertTrue(files.length() >= 0, msg = "Expected document search to complete without error");
}

@test:Config {}
function testGetFormsByName() returns error? {
    log:printInfo("driveClient -> testGetFormsByName()");
    stream<File> fileStream = check driveClient->getFormsByName("TestFile");
    File[] files = from File f in fileStream select f;
    test:assertTrue(files.length() >= 0, msg = "Expected form search to complete without error");
}

@test:Config {}
function testGetSlidesByName() returns error? {
    log:printInfo("driveClient -> testGetSlidesByName()");
    stream<File> fileStream = check driveClient->getSlidesByName("TestFile");
    File[] files = from File f in fileStream select f;
    test:assertTrue(files.length() >= 0, msg = "Expected slides search to complete without error");
}

@test:Config {}
function testGetFoldersByName() returns error? {
    log:printInfo("driveClient -> testGetFoldersByName()");
    stream<File> fileStream = check driveClient->getFoldersByName("TestFolder");
    File[] files = from File f in fileStream select f;
    test:assertTrue(files.length() > 0, msg = "Expected at least one folder by name");
}

// ---------------------------------------------------------------------------
// File update operations
// ---------------------------------------------------------------------------

@test:Config {
    dependsOn: [testCreateFile]
}
function testRenameFile() returns error? {
    log:printInfo("driveClient -> testRenameFile()");
    File response = check driveClient->renameFile(createdFileId, "TestFile_renamed");
    test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expected a file ID after rename");
    log:printInfo("Renamed file ID: " + response?.id.toString());
}

@test:Config {
    dependsOn: [testCreateFolder, testCreateFile]
}
function testMoveFile() returns error? {
    log:printInfo("driveClient -> testMoveFile()");
    File response = check driveClient->moveFile(createdFileId, createdFolderId);
    test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expected a file ID after move");
    log:printInfo("Moved file ID: " + response?.id.toString());
}

@test:Config {
    dependsOn: [testCreateFile]
}
function testUpdateFileMetadata() returns error? {
    log:printInfo("driveClient -> testUpdateFileMetadata()");
    FileMetadata payload = {
        name: "TestFile_updated",
        description: "Updated description"
    };
    File response = check driveClient->updateFileMetadataById(createdFileId, payload);
    test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expected a file ID after update");
    log:printInfo("Updated file ID: " + response?.id.toString());
}

// ---------------------------------------------------------------------------
// Copy file
// ---------------------------------------------------------------------------

@test:Config {
    dependsOn: [testCreateFile]
}
function testCopyFile() returns error? {
    log:printInfo("driveClient -> testCopyFile()");
    File response = check driveClient->copyFile(createdFileId);
    test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expected an ID for the copied file");
    log:printInfo("Copied file ID: " + response?.id.toString());
}

// ---------------------------------------------------------------------------
// Upload operations
// ---------------------------------------------------------------------------

@test:Config {}
function testUploadFileUsingByteArray() returns error? {
    log:printInfo("driveClient -> testUploadFileUsingByteArray()");
    byte[] byteArray = [116, 101, 115, 116, 45, 115, 116, 114, 105, 110, 103];
    File response = check driveClient->uploadFileUsingByteArray(byteArray, "ByteArrayFile");
    test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expected a file ID after byte-array upload");
    log:printInfo("Uploaded file ID: " + response?.id.toString());
}

@test:Config {}
function testUploadFile() returns error? {
    log:printInfo("driveClient -> testUploadFile()");
    File response = check driveClient->uploadFile(LOCAL_FILE_PATH);
    test:assertNotEquals(response?.id, EMPTY_STRING, msg = "Expected a file ID after file upload");
    log:printInfo("Uploaded file ID: " + response?.id.toString());
}

// ---------------------------------------------------------------------------
// Changes API
// ---------------------------------------------------------------------------

@test:Config {}
function testGetStartPageToken() returns error? {
    log:printInfo("driveClient -> testGetStartPageToken()");
    string token = check driveClient->getStartPageToken();
    test:assertNotEquals(token, EMPTY_STRING, msg = "Expected a non-empty start page token");
    log:printInfo("Start page token: " + token);
}

@test:Config {
    dependsOn: [testGetStartPageToken]
}
function testListChanges() returns error? {
    log:printInfo("driveClient -> testListChanges()");
    string token = check driveClient->getStartPageToken();
    stream<Change> changeStream = check driveClient->listChanges(token);
    error? result = changeStream.forEach(function(Change _c) {});
    test:assertEquals(result, (), msg = "Unexpected error while iterating changes");
    log:printInfo("listChanges completed successfully");
}

// ---------------------------------------------------------------------------
// Delete file  (run last to keep other tests usable)
// ---------------------------------------------------------------------------

@test:Config {
    dependsOn: [
        testGetFileById, testGetFileContent, testDownloadFile, testExportFile,
        testRenameFile, testMoveFile, testUpdateFileMetadata, testCopyFile
    ]
}
function testDeleteFile() returns error? {
    log:printInfo("driveClient -> testDeleteFile()");
    boolean result = check driveClient->deleteFile(createdFileId);
    test:assertTrue(result, msg = "Expected true on successful deletion");
    log:printInfo("File deleted successfully");
}
