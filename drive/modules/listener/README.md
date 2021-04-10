# Google drive listener

[![Build](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-googleapis.drive.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

The Google drive listener allows you to listen for file and folders events in Google drive.
The listener can be used to track changes on the whole drive or specified folders.

<!-- TOC -->

- [Google Drive Connecter](#markdown-navigation)
    - [Introduction](#introduction)
        - [What is Google drive](#what-is-google-drive-?)
        - [Listener Overview](#listener-overview)
    - [Prerequisites](#prerequisites)
    - [Supported versions & limitations](#supported-versions-&-limitations)
    - [Quickstart](#quickstart)
    - [Samples](#samples)
        - [Notes](#notes)
        - [Sample logs](#sample-logs)
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

# Listener overview

The Google Drive Ballerina Connector allows you to access the 
[Google Drive API Version v3](https://developers.google.com/drive/api) through Ballerina. The connector can be used to implement some of the most common use cases of Google Drive. The connector provides the capability to programmatically manage files & folders in the drive.

The Google Drive Ballerina Connector supports file and folder management operations related to creating, deleting, 
updating and retrieving.

![alt text](/docs/images/connecter_overview.png?raw=true)

1. Listen to the new file creation event.
2. Listen to a new file created on a specific folder.
3. Listen to the new folder creation event.
4. Listen to new folder creation on a specific folder.
5. Listen to the file update event.
6. Listen to file deleted event.
7. Listen to file deleted event on a specific folder.
8. Listen to the folder delete event.
9. Listen to folder delete event on a specific folder.

# Prerequisites

* Java 11 Installed
Java Development Kit (JDK) with version 11 is required.

* Download the Ballerina [distribution](https://ballerinalang.org/downloads/)
Ballerina Swan Lake Alpha 4 SNAPSHOT is required.

* Domain used in the callback URL needs to be registered in google console as a verified domain.
https://console.cloud.google.com/apis/credentials/domainverification

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

# Samples 

Import the Google Drive Listener module to your Ballerina program as follows.
i.e: The client connecter is imported to create a file in the drive here.

```ballerina
    
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_drive.'listener as listen;

configurable string callbackURL = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = drive:REFRESH_URL;
configurable string refreshToken = ?;

string fileName = "<NEW_FILE_NAME>";

# Event Trigger class  
public class EventTrigger {
    
    public isolated function onNewFolderCreatedEvent(string folderId) {}

    public isolated function onFolderDeletedEvent(string folderID) {}

    public isolated function onNewFileCreatedEvent(string fileId) {
        log:printInfo("New File was created:" + fileId);
    }

    public isolated function onFileDeletedEvent(string fileId) {}

    public isolated function onNewFileCreatedInSpecificFolderEvent(string fileId) {}

    public isolated function onNewFolderCreatedInSpecificFolderEvent(string folderId) {}

    public isolated function onFolderDeletedInSpecificFolderEvent(string folderId) {}

    public isolated function onFileDeletedInSpecificFolderEvent(string fileId) {}

    public isolated function onFileUpdateEvent(string fileId) {}
}

    drive:Configuration config = {
        clientConfig: {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshUrl: refreshUrl,
            refreshToken: refreshToken
        }
    };

    listen:ListenerConfiguration configuration = {
        port: 9090,
        callbackURL: callbackURL,
        clientConfiguration: config,
        eventService: new EventTrigger()
    };

    listener listen:DriveEventListener gDrivelistener = new (configuration);

    service / on gDrivelistener {
        resource function post gdrive(http:Caller caller, http:Request request) returns string|error? {
            error? procesOutput = gDrivelistener.findEventType(caller, request);
            http:Response response = new;
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error in responding ", err = result);
            }
        }
    }

public function main() returns error? {
    drive:Client driveClient = check new (config);
    drive:File|error response = driveClient->createFile(fileName);
    if (response is drive:File) {
        log:printInfo(response.toString());
    }
}

```
## Notes : 

1. The above example is used to listen for file creation only. Implement all needed methods in the `EventTrigger` class.

```
# Event Trigger class  
public class EventTrigger {
    
    public isolated function onNewFolderCreatedEvent(string folderId) {
        log:printInfo("New folder was created:" + folderId);
    }

    public isolated function onFolderDeletedEvent(string folderID) {
        log:printInfo("This folder was removed to the trashed:" + folderID);
    }

    public isolated function onNewFileCreatedEvent(string fileId) {
        log:printInfo("New File was created:" + fileId);
    }

    public isolated function onFileDeletedEvent(string fileId) {
        log:printInfo("This File was removed to the trashed:" + fileId);
    }

    public isolated function onNewFileCreatedInSpecificFolderEvent(string fileId) {
        log:printInfo("A file with Id " + fileId + "was created in side the folder specified");
    }

    public isolated function onNewFolderCreatedInSpecificFolderEvent(string folderId) {
        log:printInfo("A folder with Id " + folderId + "was created in side the folder specified");
    }

    public isolated function onFolderDeletedInSpecificFolderEvent(string folderId) {
        log:printInfo("A folder with Id " + folderId + "was deleted in side the folder specified");
    }

    public isolated function onFileDeletedInSpecificFolderEvent(string fileId) {
        log:printInfo("A file with Id " + fileId + "was deleted in side the folder specified");
    }
    public isolated function onFileUpdateEvent(string fileId) {
        log:printInfo("File updated : " + fileId);
    }
}
```

2. If the listener should listen for changes only in a specific folder, specify the folder Id in `ListenerConfiguration`.

```
    listen:ListenerConfiguration configuration = {
        port: 9090,
        callbackURL: callbackURL,
        clientConfiguration: config,
        eventService: new EventTrigger(),
        specificFolderOrFileId : parentFolderId
    };
```

## Sample logs

### Logs on listener startup

```
googleapis_drive.listener
time = 2021-03-15 12:03:15,797 level = INFO  module = ballerinax/googleapis_drive message = "{"kind":"api#channel","id":"01eb8595-de58-1926-b49b-6cad0df9c80c","resourceId":"GYFfeabdbAp2FoyZm2KDfQMKd1Q","resourceUri":
https://www.googleapis.com/drive/v3/changes?includeCorpusRemovals=false&includeItemsFromAllDrives=false
&includeRemoved=true&includeTeamDriveItems=false&pageSize=100&pageToken=121208&restrictToMyDrive=false&spaces=drive&supportsAllDrives=true&supportsTeamDrives=false&alt=json","expiration":"1615793595000"}" 
time = 2021-03-15 12:03:40,444 level = INFO  module = ballerinax/googleapis_drive.listener message = "10475" 
time = 2021-03-15 12:03:40,445 level = INFO  module = ballerinax/googleapis_drive.listener message = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" 
time = 2021-03-15 12:03:40,445 level = INFO  module = ballerinax/googleapis_drive.listener message = 
"Watch channel started in Google, id : 01eb8595-de58-1926-b49b-6cad0df9c80c" 
time = 2021-03-15 12:03:40,446 level = INFO  module = ballerinax/googleapis_drive.listener message = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" 
[ballerina/http] started HTTP/WS listener 0.0.0.0:9090
time = 2021-03-15 12:03:40,474 level = INFO  module = ballerinax/googleapis_drive.listener message = 
"gDriveClient -> watchFiles()"
```

### Logs on receiving a callback

```
time = 2021-03-15 12:06:19,314 level = INFO  module = ballerinax/googleapis_drive.listener message = 
"<<<<<<<<<<<<<<< RECEIVING A CALLBACK <<<<<<<<<<<<<<<" 
time = 2021-03-15 12:06:19,316 level = INFO  module = ballerinax/googleapis_drive message = 
"/drive/v3/changes?pageToken=121208" 
time = 2021-03-15 12:06:19,644 level = INFO  module = ballerinax/googleapis_drive.listener message = 
"Whole drive watch response processing" 
time = 2021-03-15 12:06:20,030 level = INFO  module = ballerinax/googleapis_drive.listener message = 
">>>>> INCOMING TRIGGER >>>>> File change event found file id : 1A3xvEHoCSx-NryIg2IZOyst5uo5guSAtqem2VYFhgPk | 
Mime type : application/vnd.google-apps.document" 
time = 2021-03-15 12:06:20,448 level = INFO  module = ballerinax/googleapis_drive.listener message = 
"This File was removed to the trashed:1A3xvEHoCSx-NryIg2IZOyst5uo5guSAtqem2VYFhgPk" 
time = 2021-03-15 12:06:40,798 level = INFO  module = ballerinax/googleapis_drive.listener message = "10474" 
time = 2021-03-15 12:06:40,798 level = INFO  module = ballerinax/googleapis_drive.listener message = 
"<<<<<<<<<<<<<<< RECEIVED >>>>>>>>>>>>>>>" 
```
# Building from the Source

### Setting Up the Prerequisites

1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptopenjdk.net/)

        > **Note:** Set the JAVA_HOME environment variable to the pathname of the directory into which you installed JDK.

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
    bal build --skip-tests
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
