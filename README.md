# module-ballerinax-googleapis.drive
Connector repository for Google Drive API V3.

### Google drive connecter
Connects to Google Drive from Ballerina.
This connecter consists of 2 modules. Client connecter and listener.

# Package overview
The Google Drive client connecter allows you to access Google Drive operations through the Google Drive REST API while 
listener provide triggers on creation, deletion and update events for files and folders. 

## Compatibility

|                             |            Versions             |
|:---------------------------:|:-------------------------------:|
| Ballerina Language          |     Swan Lake Alpha2            |
| Google Drive API            |             V3                  |

## Sample

Instantiate the connector by giving authentication details in the HTTP client config. 
The HTTP client config has built-in support for OAuth 2.0. Google Drive uses OAuth 2.0 to authenticate 
and authorize requests. The Google Drive connector can be minimally instantiated in the HTTP client config using the 
access token or the client ID, client secret, and refresh token.

**Obtaining tokens to run the sample**

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and 
follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (
    enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the 
access token and refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), 
select the required Google Calendar scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the 
refresh token and access token. 

**Add project configurations file**

Add the project configuration file by creating a `Config.toml` file under the root path of the project structure.
This file should have following configurations. Add the tokens obtained in the previous step to the `Config.toml` file.

```
[ballerinax.googleapis_drive]
clientId = "<client_id">
clientSecret = "<client_secret>"
refreshToken = "<refresh_token>"
```
**Example code**

Creating a drive:driveClient by giving the HTTP client config details. 

```ballerina
    import ballerina/config;   
    import ballerinax/googleapis_drive as drive;

    configurable string clientId = ?;
    configurable string clientSecret = ?;
    configurable string refreshToken = ?;
    configurable string refreshUrl = ?;

    Configuration config = {
        clientConfig: {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshUrl: refreshUrl,
            refreshToken: refreshToken
        }
    };

    drive:Client driveClient = new (config);
```
There is support for providing configuration using access token also.

```
Access token support
Configuration config = {
    clientConfig: {
        token: os:getEnv("ACCESS_TOKEN")
    }
};

```

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
    stream<File>|error response = driveClient->getFilesByName("ballerina", 2);
    stream<File>|error response = driveClient->getFilesByName("ballerina", 2, "createdTime");
```
### Search folders by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getFoldersByName("ballerina");
    stream<File>|error response = driveClient->getFoldersByName("ballerina", 2);
    stream<File>|error response = driveClient->getFoldersByName("ballerina", 2, "createdTime");
```

### Filter files
```ballerina
    stream<File>|error response = driveClient->filterFiles(filterString);
    stream<File>|error response = driveClient->filterFiles(filterString, 2);
    stream<File>|error response = driveClient->filterFiles(filterString, 4, "createdTime");
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
            log:print(response?.id.toString());
        });
    } else {
        log:printError(response.message());
    }
```
### Search Google spreadsheets by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina");
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina", 2);
    stream<File>|error response = driveClient->getSpreadsheetsByName("ballerina", 2, "createdTime");
```
### Search Google documents by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getDocumentsByName("ballerina");
    stream<File>|error response = driveClient->getDocumentsByName("ballerina", 3);
    stream<File>|error response = driveClient->getDocumentsByName("ballerina", 2, "createdTime");
```
### Search Google forms by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getFormsByName("ballerina");
    stream<File>|error response = driveClient->getFormsByName("ballerina", 2);
    stream<File>|error response = driveClient->getFormsByName("ballerina", 2, "createdTime");
```
### Search Google slides by name (Partial search)
```ballerina
    stream<File>|error response = driveClient->getSlidesByName("ballerina");
    stream<File>|error response = driveClient->getSlidesByName("ballerina", 2);
    stream<File>|error response = driveClient->getSlidesByName("ballerina", 2, "createdTime");
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
#### How to get a id from a file or folder in Google drive
1. Go to Google drive https://drive.google.com/drive/u/0/my-drive
2. Right click on a folder or file.
3. Click 'Get link'. Then copy the link.
4. You can find the ID in the link copied or You can get the id directly from the browser url after clicking on the file
![alt text](/metadata/extractIDfromUrl.jpeg?raw=true)

#### Limitations
Google api supports Files, Permissions, Changes, Replies, Revisions, Drives and Channels.
Currently, Google drive connecter supports operations related to Files, Channels and Changes only. It doesnt support
admin related operations.

