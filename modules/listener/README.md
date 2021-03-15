## Google drive listener

The Google drive listener allows you to listen for file and folders events in the Google drive.
Listner can be used to track changes on the whole drive or specified folders.

## Compatibility

|                             |            Versions             |
|:---------------------------:|:-------------------------------:|
| Ballerina Language          |     Swan Lake Alpha2            |
| Google Drive API            |             V3                  |

## Feature overview
1. Listen to new file creation event.
2. Listen to new file creation on a specific folder.
3. Listen to new folder creation event.
4. Listen to new folder creation on a specific folder.
5. Listen to file update event.

## Prerequisite
Domain used in the CallbackURL need to be registered in google console as a verified domain.
https://console.cloud.google.com/apis/credentials/domainverification

## Getting started
1. Refer the Get Started section to download and install Ballerina.
2. Import the Google Drive Listner module to your Ballerina program as follows.

i.e : Client connecter is imported to create a file in the drive here.

```ballerina
	
import ballerina/http;
import ballerina/log;
import nuwantissera/googleapis_drive as drive;
import nuwantissera/googleapis_drive.'listener as listen;

configurable string callbackURL = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = drive:REFRESH_URL;
configurable string refreshToken = ?;

string fileName = "<NEW_FILE_NAME>";

# Event Trigger class  
public class EventTrigger {
    
    public function onNewFolderCreatedEvent(string folderId) {}

    public function onFolderDeletedEvent(string folderID) {}

    public function onNewFileCreatedEvent(string fileId) {
        log:print("New File was created:" + fileId);
    }

    public function onFileDeletedEvent(string fileId) {}

    public function onNewFileCreatedInSpecificFolderEvent(string fileId) {}

    public function onNewFolderCreatedInSpecificFolderEvent(string folderId) {}

    public function onFolderDeletedInSpecificFolderEvent(string folderId) {}

    public function onFileDeletedInSpecificFolderEvent(string fileId) {}

    public function onFileUpdateEvent(string fileId) {}
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
        resource function post gsheet(http:Caller caller, http:Request request) returns string|error? {
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
        log:print(response.toString());
    }
}

```
The above example is used to listen for file creation. Implement only needed method in `EventTrigger` class.

