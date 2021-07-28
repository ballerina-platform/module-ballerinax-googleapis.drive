## Overview
The module provides the capability to programmatically manage files and folders in the [Google Drive](https://drive.google.com).

This module supports [Google Drive API v3](https://developers.google.com/drive/api) operations related to Files, Channels and Changes only. It does not support admin related operations like creating new shared drives.

## Prerequisites
- [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp)
- Obtaining tokens - Follow [this link](https://developers.google.com/identity/protocols/oauth2)

## Quickstart
To use the Google Drive connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import the Google Drive module
First, import the ballerinax/googleapis.drive module into the Ballerina project.
```ballerina
import ballerinax/googleapis.drive;
```
All the actions return a valid response or error. If the action is a success, then the requested resource will be returned. Else error will be returned.

### Step 2: Initialize the Google Drive client
In order for you to use the Drive Endpoint, first, you need to create a Google Drive Client endpoint.
```ballerina

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = drive:REFRESH_URL;

drive:Configuration config = {
    clientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
    }
};

drive:Client driveClient = new (config);
```
### Step 3: Add get file function
Create a quick add event using `quickAddEvent` remote function.

```ballerina
string fileId = "xxx";

drive:File response = check driveClient->getFile(fileId);
```
## Quick reference

- Get file by ID
    ```ballerina
    File|error response = driveClient->getFile(fileId);
    ```
- Get file content by ID
    ```ballerina
    FileContent|error response = driveClient->getFileContent(fileId);
    ```
- Copy file
    ```ballerina
    File|error response = driveClient->copyFile(sourceFileId);
    File|error response = driveClient->copyFile(sourceFileId, destinationFolderId);
    File|error response = driveClient->copyFile(sourceFileId, destinationFolderId, newFileName);
    ```
- Move file
    ```ballerina
    File|error response = driveClient->moveFile(sourceFileId, destinationFolderId);
    ```
- Rename file
    ```ballerina
    File|error response = driveClient->renameFile(fileId, newFileName);
    ```
- Create folder
    ```ballerina
    File|error response = driveClient->createFolder(folderName);
    File|error response = driveClient->createFolder(folderName, parentFolderId);
    ```
- Create file
    ```ballerina
    File|error response = driveClient->createFile(fileName);
    File|error response = driveClient->createFile(fileName, mimeType);
    File|error response = driveClient->createFile(fileName, mimeType, parentFolderId);
    ```

- Search files by name (Partial search)
    ```ballerina
    stream<File>|error response = driveClient->getFilesByName("ballerina");
    stream<File>|error response = driveClient->getFilesByName("ballerina", "createdTime");
    ```
- Search folders by name (Partial search)
    ```ballerina
    stream<File>|error response = driveClient->getFoldersByName("ballerina");
    stream<File>|error response = driveClient->getFoldersByName("ballerina", "createdTime");
    ```

- How generate a the filter string

    | What you want to query                                               |    Example                                                             |
    | ---------------------------------------------------------------------|------------------------------------------------------------------------|
    |Files with the name "hello"                                           |     name = 'hello'                                                     |
    |Files with a name containing the words "hello" and "goodbye"          |     name contains 'hello' and name contains 'goodbye'                  |
    |Files with a name that does not contain the word "hello"              |     not name contains 'hello'                                          |   
    |Folders that are Google apps or have the folder MIME type             |     mimeType = 'application/vnd.google-apps.folder'                    |
    |Files that are not folders                                            |     mimeType != 'application/vnd.google-apps.folder'                   |
    |Files that contain the text "important" and in the trash              |     fullText contains 'important' and trashed = true                   |
    |Files that contain the word "hello"                                   |     fullText contains 'hello'                                          |
    |Files that do not have the word "hello"                               |     not fullText contains 'hello'                                      |
    |Files that contain the exact phrase "hello world"                     |     fullText contains '"hello world"'                                  |
    |Files with a query that contains the "" character (e.g., "\authors")  |     fullText contains '\\authors'                                      |
    |Files with ID within a collection, e.g. parents collection            |     '1234567' in parents                                               |
    |Files in an Application data folder in a collection                   |     'appDataFolder' in parents                                         |
    |Files for which user "test@example.org" has write permission          |     'test@example.org' in writers                                      |
    |Files modified after a given date                                     |      modifiedTime > '2012-06-04T12:00:00' // default time zone is UTC  |
    |Files shared with the authorized user with "hello" in the name        |      sharedWithMe and name contains 'hello'                            |

- Get all files
    ```ballerina
    drive:stream<File>|error res = driveClient->getAllFiles();
    ```

- Get all Google spreadsheets
    ```ballerina
    stream<File>|error response = driveClient->getAllSpreadsheets();
     if (response is stream<File>){
        error? e = response.forEach(isolated function (File response) {
            log:printInfo(response?.id.toString());
        });
    } else {
        log:printError(response.message());
    }
    ```

- Search Google spreadsheets by name (Partial search)
    ```ballerina
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina");
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina", "createdTime");
    ```

- Search Google documents by name (Partial search)
    ```ballerina
    stream<File>|error response = driveClient->getDocumentsByName("ballerina");
    stream<File>|error response = driveClient->getDocumentsByName("ballerina", "createdTime");
    ```

- Search Google forms by name (Partial search)
    ```ballerina
    stream<File>|error response = driveClient->getFormsByName("ballerina");
    stream<File>|error response = driveClient->getFormsByName("ballerina", "createdTime");
    ```

- Search Google slides by name (Partial search)
    ```ballerina
    stream<File>|error response = driveClient->getSlidesByName("ballerina");
    stream<File>|error response = driveClient->getSlidesByName("ballerina", "createdTime");
    ```

- Update metadata in a file
    ```ballerina
    UpdateFileMetadataOptional optionalsFileMetadata = {
        addParents : parentFolder
    };
    FileMetadata payloadFileMetadata = {
        name : "test"
    };
    File|error res = driveClient->updateFileMetadataById(fileId, optionalsFileMetadata, payloadFileMetadata);
    ```

- Download file
    ```ballerina
    string|error response = driveClient->downloadFile(fileId);
    ```

- Delete file by ID
    ```ballerina
    boolean|error response = driveClient->deleteFile(fileId);
    ```

- Upload file
    ```ballerina
    File|error response = driveClient->uploadFile(localFilePath);
    File|error response = driveClient->uploadFile(localFilePath, fileName);
    File|error response = driveClient->uploadFile(localFilePath, fileName, parentFolderId);
    ```

- Upload file using a byte array
    ```ballerina
    byte[] byteArray = [116,101,115,116,45,115,116,114,105,110,103];
    File|error response = driveClient->uploadFileUsingByteArray(byteArray, fileName);
    File|error response = driveClient->uploadFileUsingByteArray(byteArray, fileName, parentFolderId);
    ```

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/tree/main/drive/samples)**
