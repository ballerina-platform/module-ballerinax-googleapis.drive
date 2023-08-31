## Overview
The connector provides the capability to programmatically manage files and folders in the [Google Drive](https://drive.google.com).

This module supports [Google Drive API v3](https://developers.google.com/drive/api).

## Prerequisites
Before using this connector in your Ballerina application, complete the following:

- [Create a Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp)
- Obtain tokens - Follow [this link](https://developers.google.com/identity/protocols/oauth2)

## Quickstart
To use the Google Drive connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import the connector
Import the ballerinax/googleapis.drive module into the Ballerina projects shown below.
```ballerina
import ballerinax/googleapis.drive;
```
All the actions return a valid response or error. If the action is a success, then the requested resource is returned. If not, an error is returned.

### Step 2: Create a new connector instance
Create a drive:ConnectionConfig with the OAuth2 tokens obtained, and initialize the connector with it.
```ballerina

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = drive:REFRESH_URL;

drive:ConnectionConfig config = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
    }
};

drive:Client driveClient = new (config);
```
### Step 3: Invoke the connector operation
1. Now you can use the operations available within the connector. Note that they are in the form of remote operations.

    Following is an example on how to retrieve a file using the connector.

    Get file with given file ID
    ```ballerina
        public function main() returns error? {
            drive:File response = check driveClient->getFile(fileId);
            log:printInfo("Successfully retreived the file.");
        }
    ```

2. Use `bal run` command to compile and run the Ballerina program.

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/tree/main/examples)**
