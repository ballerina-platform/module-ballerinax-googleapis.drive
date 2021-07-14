## Overview

This module provides you a notification when following events are occurred in the drive.
- Listen to the new file creation event.
- Listen to a new file created on a specific folder.
- Listen to the new folder creation event.
- Listen to new folder creation on a specific folder.
- Listen to the file update event.
- Listen to file deleted event.
- Listen to file deleted event on a specific folder.
- Listen to the folder delete event.
- Listen to folder delete event on a specific folder.

This module supports [Google Drive API v3](https://developers.google.com/drive/api) version.

### Prerequisites
- [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp)
* [Domain used in the callback URL needs to be registered in google console as a verified domain.](https://console.cloud.google.com/apis/credentials/domainverification)
(If you are running locally, provide your ngrok url as to the domain verification). Then you will be able to download a HTML file (e.g : google2c627a893434d90e.html). Copy the content of that HTML file & provide that as a config (`domainVerificationFileContent`) to Listener initialization. In case if you failed to verify or setup, refer the [documentation](https://docs.google.com/document/d/119jTQ1kpgg0hpNl1kycfgnGUIsm0LVGxAvhrd5T4YIA/edit?usp=sharing) for domain verification process.

- Obtaining tokens - Follow [this link](https://developers.google.com/identity/protocols/oauth2)

## Quickstart

To use the Google Calendar connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import Google Drive module
Import the Google Drive Listener module to your Ballerina program as follows.
i.e: The client connecter is imported to create a file in the drive here.

```ballerina
import ballerinax/googleapis.drive;
import ballerinax/googleapis.drive.'listener as listen;
```
### Step 2: Initialize the Google Drive configuration
```ballerina
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
```
### Step 3: Initialize the Drive listener
```ballerina
listener listen:DriveEventListener gDrivelistener = new (configuration);
```
### Step 4: Create the listener service
```ballerina
service / on gDrivelistener {
    isolated remote function onFileCreate(Change changeInfo) returns error? {
        log:printInfo("Trigger > onFileCreate > changeInfo : ", changeInfo);     
    }
}
```

## Quick reference

- If the listener should listen for changes only in a specific folder, specify the folder Id in `ListenerConfiguration`.
    ```
    listen:ListenerConfiguration configuration = {
        port: 9090,
        callbackURL: callbackURL,
        clientConfiguration: config,
        domainVerificationFileContent : domainVerificationFileContent,
        specificFolderOrFileId : parentFolderId
    };
    ```
- If you want to specify a custom retry configuration values. Specify it in the listener configuration as `channelRenewalConfig`.
    ```
    listen:ListenerConfiguration configuration = {
        port: 9090,
        callbackURL: callbackURL,
        clientConfiguration: config,
        domainVerificationFileContent : domainVerificationFileContent,
        specificFolderOrFileId : parentFolderId,
        ChannelRenewalConfig channelRenewalConfig?;
    };
    ```
**NOTE:**
At user function implementation if there was an error we throw it up & the http client will return status 500 error. 
If no any error occurred & the user logic is executed successfully we respond with status 200 OK. 
If the user logic in listener remote operations include heavy processing, the user may face http timeout issues. 
To solve this issue, user must use asynchronous processing when it includes heavy processing.

```ballerina
listener listen:Listener gDrivelistener = new (configuration);

service / on gDrivelistener {
    remote function onFileCreate(listen:Change event) returns error? {
        _ = @strand { thread: "any" } start userLogic(event);
    }
}

function userLogic(listen:Change event) returns error? {
    // Write your logic here
}
```
**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/tree/main/drive/samples/listener_sample)**
