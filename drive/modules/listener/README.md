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
Ballerina Swan Lake Alpha 5 is required.

* Domain used in the callback URL needs to be registered in google console as a verified domain.
https://console.cloud.google.com/apis/credentials/domainverification
(If you are running locally, provide your ngrok url as to the domain verification)
Then you will be able to download a HTML file (e.g : google2c627a893434d90e.html). 
Copy the content of that HTML file & provide that as a config (`domainVerificationFileContent`) to Listener initialization.

* In case if you failed to verify or setup, Please refer the documentation for domain verification process 
https://docs.google.com/document/d/119jTQ1kpgg0hpNl1kycfgnGUIsm0LVGxAvhrd5T4YIA/edit?usp=sharing

# Supported versions & limitations

## Supported Versions

|                             |            Versions             |
|:---------------------------:|:-------------------------------:|
| Ballerina Language          |     Swan Lake Alpha 5           |
| Google Drive API            |             V3                  |

## Limitations

Google API v3 supports resource types - Files, Permissions, Changes, Replies, Revisions, Drives and Channels. Currently, 
Google drive connecter supports operations related to Files, Channels and Changes only. .It doesn't support admin related operations like creating new shared drives.

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
import ballerinax/googleapis.drive as drive;
import ballerinax/googleapis.drive.'listener as listen;

configurable string callbackURL = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = drive:REFRESH_URL;
configurable string refreshToken = ?;
configurable string domainVerificationFileContent = ?

string fileName = "<NEW_FILE_NAME>";

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
        domainVerificationFileContent : domainVerificationFileContent,
        clientConfiguration: config
    };

    listener listen:DriveEventListener gDrivelistener = new (configuration);

    service / on gDrivelistener {
        isolated remote function onFileCreate(drive:Change changeInfo) returns error? {
            log:printInfo("Trigger > onFileCreate > changeInfo : ", changeInfo);     
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

1. If the listener should listen for changes only in a specific folder, specify the folder Id in `ListenerConfiguration`.

```
    listen:ListenerConfiguration configuration = {
        port: 9090,
        callbackURL: callbackURL,
        clientConfiguration: config,
        domainVerificationFileContent : domainVerificationFileContent,
        specificFolderOrFileId : parentFolderId
    };
```
2. If you want to specify a custom expiration time. Specify it in the listener configuration.
```
    listen:ListenerConfiguration configuration = {
        port: 9090,
        callbackURL: callbackURL,
        clientConfiguration: config,
        domainVerificationFileContent : domainVerificationFileContent,
        specificFolderOrFileId : parentFolderId,
        expiration : 100000
    };
```

## Sample logs

### Logs on listener startup

```
[ballerina/http] started HTTP/WS listener 0.0.0.0:9090
time = 2021-04-21 22:33:23,203 level = INFO  module = ballerinax/googleapis.drive.listener message = "Watch channel started in Google, id : 01eba304-074c-1c34-a0c4-16fed7d5b321" 
time = 2021-04-21 22:33:23,212 level = INFO  module = ballerinax/googleapis.drive.listener message = "gDriveClient -> watchFiles()" 

```

### Logs on receiving a callback

```

time = 2021-04-21 22:36:59,110 level = INFO  module = ballerinax/googleapis.drive.listener message = "Trigger > onFileTrash > changeInfo : " kind = "drive#change" changeType = "file" time = "2021-04-21T17:03:41.249Z" removed = false fileId = "1nRyPs-Hxl4A875YROR6cj9jnFzTPgw0k-FoWyWuQOuc" file = {"kind":"drive#file","id":"1nRyPs-Hxl4A875YROR6cj9jnFzTPgw0k-FoWyWuQOuc","name":"Untitled form","mimeType":"application/vnd.google-apps.form"} type = "file

```
# Building from the Source

### Setting Up the Prerequisites

1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptopenjdk.net/)

        > **Note:** Set the JAVA_HOME environment variable to the pathname of the directory into which you installed JDK.

2. Download and install [Ballerina Alpha 5 ](https://ballerina.io/). 

### Building the Source

Execute the commands below to build from the source after installing Ballerina Alpha 5 version.

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
