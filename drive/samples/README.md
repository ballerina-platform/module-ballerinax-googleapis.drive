# Ballerina Google Drive connector samples:
### Get file by id
```ballerina
    File|error response = driveClient->getFile(fileId);
```
### Download file
```ballerina
    string|error response = driveClient->downloadFile(fileId);
```
### Delete File by id
```ballerina
    boolean|error response = driveClient->deleteFile(fileId);
```
### Copy File
```ballerina
    File|error response = driveClient->copyFile(sourceFileId);
    File|error response = driveClient->copyFile(sourceFileId, destinationFolderId);
    File|error response = driveClient->copyFile(sourceFileId, destinationFolderId, newFileName);
```
### Move File
```ballerina
    File|error response = driveClient->moveFile(sourceFileId, destinationFolderId);
```
### Rename File
```ballerina
    File|error response = driveClient->renameFile(fileId, newFileName);
```
### Rename File
```ballerina
    File|error response = driveClient->renameFile(fileId, newFileName);
```
### Create folder
```ballerina
    File|error response = driveClient->createFolder(folderName);
    File|error response = driveClient->createFolder(folderName, parentFolderId);
```
### Create file
```ballerina
    File|error response = driveClient->createFile(fileName);
    File|error response = driveClient->createFile(fileName, mimeType);
    File|error response = driveClient->createFile(fileName, mimeType, parentFolderId);
```

### Search files by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getFilesByName("ballerina");
    stream<File>|error response = driveClient->getFilesByName("ballerina", "createdTime");
```
### Search folders by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getFoldersByName("ballerina");
    stream<File>|error response = driveClient->getFoldersByName("ballerina", "createdTime");
```

### Filter files
```ballerina
    stream<File>|error response = driveClient->filterFiles(filterString);
    stream<File>|error response = driveClient->filterFiles(filterString, "createdTime");
```

| What you want to query                                               |    Example                                                             |
| ---------------------------------------------------------------------|------------------------------------------------------------------------|
|Files with the name "hello"					                       |     name = 'hello'                                                     |
|Files with a name containing the words "hello" and "goodbye"	       |     name contains 'hello' and name contains 'goodbye'                  |
|Files with a name that does not contain the word "hello"	           |     not name contains 'hello'                                          |   
|Folders that are Google apps or have the folder MIME type	           |     mimeType = 'application/vnd.google-apps.folder'                    |
|Files that are not folders					                           |     mimeType != 'application/vnd.google-apps.folder'                   |
|Files that contain the text "important" and in the trash	           |     fullText contains 'important' and trashed = true                   |
|Files that contain the word "hello"				                   |     fullText contains 'hello'                                          |
|Files that do not have the word "hello"				               |     not fullText contains 'hello'                                      |
|Files that contain the exact phrase "hello world"		               |     fullText contains '"hello world"'                                  |
|Files with a query that contains the "" character (e.g., "\authors")  |     fullText contains '\\authors'                                      |
|Files with ID within a collection, e.g. parents collection	           |     '1234567' in parents                                               |
|Files in an Application data folder in a collection	               |     'appDataFolder' in parents                                         |
|Files for which user "test@example.org" has write permission	       |     'test@example.org' in writers                                      |
|Files modified after a given date	                                   |      modifiedTime > '2012-06-04T12:00:00' // default time zone is UTC  |
|Files shared with the authorized user with "hello" in the name	       |      sharedWithMe and name contains 'hello'                            |

### Get All files
```ballerina
    drive:stream<File>|error res = driveClient->getAllFiles();
```

## Workspace related functions
### Get All Google spreadsheets
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
### Search Google spreadsheets by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina");
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina", "createdTime");
```
### Search Google documents by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getDocumentsByName("ballerina");
    stream<File>|error response = driveClient->getDocumentsByName("ballerina", "createdTime");
```
### Search Google forms by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getFormsByName("ballerina");
    stream<File>|error response = driveClient->getFormsByName("ballerina", "createdTime");
```
### Search Google slides by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getSlidesByName("ballerina");
    stream<File>|error response = driveClient->getSlidesByName("ballerina", "createdTime");
```
### Update metadata in a file
```ballerina
    UpdateFileMetadataOptional optionalsFileMetadata = {
        addParents : parentFolder
    };
    File payloadFileMetadata = {
        name : "test"
    };
    File|error res = driveClient->updateFileMetadataById(fileId, optionalsFileMetadata, payloadFileMetadata);
```
### Delete file by id
More details : https://developers.google.com/drive/api/v3/reference/files/delete
```ballerina
    boolean|error response = driveClient->deleteFile(fileId);   
```
### Create folder with metadata
More details : https://developers.google.com/drive/api/v3/reference/files/update
```ballerina
    CreateFileOptional optionals_create_folder = {
        ignoreDefaultVisibility : false
    };
    File payload_create_folder = {
        mimeType : "application/vnd.google-apps.folder",
        name : "folderInTheRoot"
    };
    File|error res = driveClient->createMetaDataFile(optionals_create_folder, payload_create_folder);
```

### Upload file
```ballerina
    File|error response = driveClient->uploadFile(localFilePath);
    File|error response = driveClient->uploadFile(localFilePath, fileName);
    File|error response = driveClient->uploadFile(localFilePath, fileName, parentFolderId);
```

### Upload file using a byte array
```ballerina
    byte[] byteArray = [116,101,115,116,45,115,116,114,105,110,103];
    File|error response = driveClient->uploadFileUsingByteArray(byteArray, fileName);
    File|error response = driveClient->uploadFileUsingByteArray(byteArray, fileName, parentFolderId);
```