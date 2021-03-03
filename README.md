# module-ballerinax-googleapis.drive
Connector repository for Google Drive API V3.

### Google Drive Connecter
Connects to Google Drive from Ballerina.

# Package Overview
The Google Drive connector allows you to access Google Drive operations through the Google Drive REST API. 
It also allows you to create, retreive, search, and delete drive files and folders.

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

**Obtaining Tokens to Run the Sample**

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
**Example Code**

Creating a drive:driveClient by giving the HTTP client config details. 

```ballerina

    import ballerina/config;   
    import ballerinax/googleapis_drive as drive;

    configurable string clientId = ?;
    configurable string clientSecret = ?;
    configurable string refreshToken = ?;

    Configuration config = {
        clientConfig: {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshUrl: REFRESH_URL,
            refreshToken: refreshToken
        }
    };

    drive:Client driveClient = new (config);

```

### Get File By Id
More details : https://developers.google.com/drive/api/v3/reference/files/get
```ballerina

    drive:File|error file = driveClient->getFileById(fileId);

```

### Get File By Id with optionals
More details : https://developers.google.com/drive/api/v3/reference/files/get
```ballerina

    GetFileOptional optional = {
        acknowledgeAbuse: false,
        fields: "*",
        supportsAllDrives : false
    };

    drive:File|error file = driveClient->getFileById(fileId, optional);

```

### Get files
More details : https://developers.google.com/drive/api/v3/reference/files/list
```ballerina

    ListFilesOptional optional_search = {
        pageSize : 3
    };
    drive:stream<File>|error res = driveClient->getFiles(optional_search);

```

### Copy file
More details : https://developers.google.com/drive/api/v3/reference/files/copy
```ballerina

    CopyFileOptional optionals_copy_file = {"includePermissionsForView" : "published"};

    File payload_copy_file = {
        name : "testfile.pdf" //New name
    };

    drive:File|error file = driveClient->copyFile(fileId ,optionals_copy_file ,payload_copy_file );

```

### Update Metadata in a file
More details : https://developers.google.com/drive/api/v3/reference/files/update
```ballerina
    
    UpdateFileMetadataOptional optionals_file_metadata = {
        addParents : parentFolder
    };

    File payload__file_metadata = {
        name : "test"
    };

    File|error res = driveClient->updateFileMetadataById(fileId, optionals_file_metadata, payload__file_metadata);

```

### Delete File by ID
More details : https://developers.google.com/drive/api/v3/reference/files/delete
```ballerina
    DeleteFileOptional delete_optional = {

        supportsAllDrives : false

    };
    json | error res = driveClient->deleteFileById(fileId, delete_optional);
```

### Create Folder with Metadata
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

### Upload File
More details : https://developers.google.com/drive/api/v3/reference/files/create
```ballerina
    UpdateFileMetadataOptional optionals_ = {
        addParents : parentFolder //Parent folderID
    };

    File payload_ = {
        name : "test123.jpeg"
    };
    string filePath = "./tests/resources/bar.jpeg";
     File|error res = driveClient->uploadFile(filePath, optionals_, payload_);
```

### Upload File Using a Byte Array
More details : https://developers.google.com/drive/api/v3/reference/files/create
```ballerina
    UpdateFileMetadataOptional optionals_ = {
        addParents : parentFolder //Parent folderID
    };

    File payload_ = {
        name : "test123.jpeg"
    };
    byte[] byteArray = [116,101,115,116,45,115,116,114,105,110,103];

    File|error res = driveClient->uploadFileUsingByteArray(byteArray, optionals_, payload_);
```

#### How to Get a ID for a file or folder in Google drive
1. Go to Gdrive https://drive.google.com/drive/u/0/my-drive
2. Right click on a folder or file.
3. Click 'Get link'. Then copy the link.
4. You can find the ID in the link copied or You can get the id directly from the browser url after clicking on the file
![alt text](/metadata/extractIDfromUrl.jpeg?raw=true)
