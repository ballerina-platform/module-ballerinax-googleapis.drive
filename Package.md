# Ballerina Google Drive Connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-googleapis.drive.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Connects to Google Drive using Ballerina.

<!-- TOC -->

- [Google Drive Connecter](#markdown-navigation)
    - [Introduction](#introduction)
        - [What is Google drive](#what-is-google-drive-?)
        - [Key features of Google Drive](#key-features-of-google-drive)
        - [Connector Overview](#connector-overview)
    - [Prerequisites](#prerequisites)
        - [Obtaining tokens](#obtaining-tokens)
        - [Add project configurations file](#add-project-configurations-file)
    - [Supported versions & limitations](#supported-versions-&-limitations)
    - [Quickstart](#quickstart)
    - [Samples](#samples)
    - [Building from the Source](#building-from-the-source)
    - [Contributing to Ballerina](#contributing-to-ballerina)
    - [Code of Conduct](#code-of-conduct)
    - [Useful Links](#useful-links)
    - [How you can contribute](#how-you-can-contribute)

<!-- /TOC -->

# Introduction

## What is Google drive?

[Google Drive](https://developers.google.com/drive/api) allows users to store files on their servers, 
synchronize files across devices, and share files. Google Drive encompasses Google Docs, Google Sheets, and Google 
Slides, which are a part of the Google Docs Editors office suite that permits the collaborative editing of documents, 
spreadsheets, presentations, drawings, forms, and more. Files created and edited through the Google Docs suite are saved in Google Drive.

![alt text](/docs/images/drive_overview.png?raw=true)

## Key features of Google Drive

* Easy and secure access to all of your content.
* Store, share and collaborate on files and folders from any mobile device, tablet or computer.
* Cloud-native collaboration apps to supercharge teamwork.
* Drive integrates seamlessly with Docs, Sheets, and Slides, cloud-native apps that enable your team to collaborate effectively in real-time.
* Integration with the tools and apps your team is already using.
* Drive integrates with and complements your team’s existing technology. 
* Drive works on all major platforms, enabling you to work seamlessly across your browser, mobile device, tablet and computer.

## Connector Overview

The Google Drive Ballerina Connector allows you to access the 
[Google Drive API Version v3](https://developers.google.com/drive/api) through Ballerina. The connector can be used to implement some of the most common use cases of Google Drive. The connector provides the capability to programmatically manage files & folders in the drive.

The Google Drive Ballerina Connector supports file and folder management operations related to creating, deleting, 
updating and retrieving.

![alt text](/docs/images/connecter_overview.png?raw=true)

# Prerequisites

* Java 11 Installed
Java Development Kit (JDK) with version 11 is required.

* Download the Ballerina [distribution](https://ballerinalang.org/downloads/)
Ballerina Swan Lake Alpha 4 SNAPSHOT is required.

* Instantiate the connector by giving authentication details in the HTTP client config. The HTTP client config has built-in support for BasicAuth and OAuth 2.0. Google Drive uses OAuth 2.0 to authenticate and authorize requests. The Google Drive connector can be minimally instantiated in the HTTP client config using the client ID, client secret, and refresh token.
    * Client ID
    * Client Secret
    * Refresh Token

## Obtaining tokens

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and 
follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (
    enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the access token and refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), 
select the required Google Calendar scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the 
refresh token and access token. 

## Add project configurations file

Add the project configuration file by creating a `Config. toml` file under the root path of the project structure.
This file should have the following configurations. Add the tokens obtained in the previous step to the `Config.toml` file.

#### Config.toml
```ballerina
[ballerinax.googleapis_drive]
clientId = "<client_id">
clientSecret = "<client_secret>"
refreshToken = "<refresh_token>"
```

# Supported versions & limitations

## Supported Versions

|                             |            Versions             |
|:---------------------------:|:-------------------------------:|
| Ballerina Language          |     Swan Lake Alpha4 SNAPSHOT   |
| Google Drive API            |             V3                  |

## Limitations

Google API v3 supports resource types - Files, Permissions, Changes, Replies, Revisions, Drives and Channels. Currently, 
Google drive connecter supports operations related to Files, Channels and Changes only. .It doesn't support admin related operations like creatin new shared drives.

# Quickstart

## Working with Google Drive Endpoint Actions

You must follow the following steps in order to obtain the tokens needed for the configuration of the Ballerina Connector.

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google Drive scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token.

### Step 1: Import the Google Drive Ballerina Library
First, import the ballerinax/googleapis_drive module into the Ballerina project.
```ballerina
import ballerinax/googleapis_drive as drive;
```
All the actions return a valid response or error. If the action is a success, then the requested resource will be returned. Else error will be returned.

### Step 2: Initialize the Google Drive Client
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
Then the endpoint actions can be invoked as `var response = driveClient->actionName(arguments)`.

#### How to get an id from a file or folder in Google drive
1. Go to Google drive https://drive.google.com/drive/u/0/my-drive
2. Right-click on a folder or file.
3. Click 'Get link'. Then copy the link.
4. You can find the ID in the link copied or You can get the id directly from the browser URL after clicking on the file
![alt text](/docs/images/file_id.jpeg?raw=true)

## Example code

Creating a drive:driveClient by giving the HTTP client config details. 

```ballerina
    import ballerina/config;   
    import ballerinax/googleapis_drive as drive;

    configurable string clientId = ?;
    configurable string clientSecret = ?;
    configurable string refreshToken = ?;
    configurable string refreshUrl = drive:REFRESH_URL;

    Configuration config = {
        clientConfig: {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshUrl: refreshUrl,
            refreshToken: refreshToken
        }
    };

    drive:Client driveClient = check new (config);
```
There is support for providing configuration using access token also.

```
Configuration config = {
    clientConfig: {
        token: os:getEnv("ACCESS_TOKEN")
    }
};
```

# Samples

### Get file by id
```ballerina
    File|error response = driveClient->getFile(fileId);
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
### Download file
```ballerina
    string|error response = driveClient->downloadFile(fileId);
```
### Delete File by id
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

# Building from the Source

### Setting Up the Prerequisites

1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptopenjdk.net/)

        > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Ballerina Alpha 4 SNAPSHOT](https://ballerina.io/). 

### Building the Source

Execute the commands below to build from the source after installing Ballerina Alpha 4 SNAPSHOT version.

1. To clone the repository:
Clone this repository using the following command:
```shell
    git clone https://github.com/ballerina-platform/module-ballerinax-googleapis.drive
```
Execute the commands below to build from the source after installing Ballerina SLP8 version.

2. To build the library:
Run this command from the module-ballerinax-googleapis.drive root directory:
```shell script
    bal build
```

3. To build the module without the tests:
```shell script
    bal build -c --skip-tests
```

## Contributing to Ballerina

As an open-source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of Conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful Links

* Discuss the code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.

## How you can contribute

Clone the repository by running the following command
`git clone https://github.com/ballerina-platform/module-ballerinax-googleapis.drive.git`

As an open-source project, we welcome contributions from the community. Check the [issue tracker](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/issues) for open issues that interest you. We look forward to receiving your contributions.
