## Overview

This module generates a notification when the following events occur in the drive.
- Creation of a new file
- The creation of a new file in a specific folder
- Creation of a new folder
- Creation of a new folder in a specific folder
- File update
- File deletion
- File deletion in a specific folder
- Folder deletion
- Folder deletion in a specific folder

This module supports [Google Drive API v3](https://developers.google.com/drive/api).

Before using this connector in your Ballerina application, complete the following:

### Prerequisites
- [Create a Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp)
* [Domain used in the callback URL needs to be registered in google console as a verified domain.](https://console.cloud.google.com/apis/credentials/domainverification)
If you are running locally, provide your ngrok url for domain verification. Then you are able to download a HTML file (e.g : google2c627a893434d90e.html). Copy the content of that HTML file and provide it as a configuration (i.e., via the domainVerificationFileContent parameter) to listener initialization.

If you fail to verify or set up, see documentation for domain verification process.

- Obtain tokens - Follow [this link](https://developers.google.com/identity/protocols/oauth2)

## Quickstart

To use the Google Calendar connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import listener
Import the Google Drive Listener module to your Ballerina program as follows.

```ballerina
import ballerinax/googleapis.drive;
import ballerinax/googleapis.drive.'listener as listen;
```

### Step 2: Create a new listener instance
Initialize the Google Drive configuration as follows.

```ballerina
drive:Configuration clientConfig = {
    clientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
    }
};

listen:ListenerConfiguration listenerConfig = {
    port: 9090,
    callbackURL: callbackURL,
    domainVerificationFileContent : domainVerificationFileContent,
    clientConfiguration: clientConfig
};

listener listen:DriveEventListener gDrivelistener = new (configuration);

```

### Step 3: Define Ballerina service with the listener
Start the listener as a service.

```ballerina
service / on gDrivelistener {
    isolated remote function onFileCreate(Change changeInfo) returns error? {
        log:printInfo("Trigger > onFileCreate > changeInfo : ", changeInfo);     
    }
}
```
**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/tree/main/drive/samples/listener_sample)**

**NOTE:**
If an error occurs at function implementation, the HTTP client returns the Status 500 error. If no error occurs and the user logic is successfully executed, there HTTP client returns status 200 OK.

If the user logic in listener remote operations includes heavy processing, you may face HTTP timeout issues. To overcome this, you should use asynchronous processing when the operation includes heavy processing.

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
