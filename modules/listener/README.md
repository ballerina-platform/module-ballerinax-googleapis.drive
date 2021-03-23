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
6. Listen to file delete event.
7. Listen to file delte event on a specific folder.
8. Listen to folder delete event.
9. Listen to folder delte event on a specific folder.

## Prerequisite
Domain used in the CallbackURL need to be registered in google console as a verified domain.
https://console.cloud.google.com/apis/credentials/domainverification

## Getting started
1. Refer the [Get Started](https://ballerina.io/v1-1/learn/) section to download and install Ballerina.
2. Import the Google Drive Listner module to your Ballerina program as follows.

i.e : Client connecter is imported to create a file in the drive here.

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
public isolated class EventTrigger {
    
    isolated function onNewFolderCreatedEvent(string folderId) {}

    isolated function onFolderDeletedEvent(string folderID) {}

    isolated function onNewFileCreatedEvent(string fileId) {
        log:print("New File was created:" + fileId);
    }

    isolated function onFileDeletedEvent(string fileId) {}

    isolated function onNewFileCreatedInSpecificFolderEvent(string fileId) {}

    isolated function onNewFolderCreatedInSpecificFolderEvent(string folderId) {}

    isolated function onFolderDeletedInSpecificFolderEvent(string folderId) {}

    isolated function onFileDeletedInSpecificFolderEvent(string fileId) {}

    isolated function onFileUpdateEvent(string fileId) {}
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
        log:print(response.toString());
    }
}

```
## Notes : 

1. The above example is used to listen for file creation only. Implement all needed methods in `EventTrigger` class.

```
# Event Trigger class  
public isolated class EventTrigger {
    
    isolated function onNewFolderCreatedEvent(string folderId) {
        log:print("New folder was created:" + folderId);
    }

    isolated function onFolderDeletedEvent(string folderID) {
        log:print("This folder was removed to the trashed:" + folderID);
    }

    isolated function onNewFileCreatedEvent(string fileId) {
        log:print("New File was created:" + fileId);
    }

    isolated function onFileDeletedEvent(string fileId) {
        log:print("This File was removed to the trashed:" + fileId);
    }

    isolated function onNewFileCreatedInSpecificFolderEvent(string fileId) {
        log:print("A file with Id " + fileId + "was created in side the folder specified");
    }

    isolated function onNewFolderCreatedInSpecificFolderEvent(string folderId) {
        log:print("A folder with Id " + folderId + "was created in side the folder specified");
    }

    isolated function onFolderDeletedInSpecificFolderEvent(string folderId) {
        log:print("A folder with Id " + folderId + "was deleted in side the folder specified");
    }

    isolated function onFileDeletedInSpecificFolderEvent(string fileId) {
        log:print("A file with Id " + fileId + "was deleted in side the folder specified");
    }
    isolated function onFileUpdateEvent(string fileId) {
        log:print("File updated : " + fileId);
    }
}
```

2. If listener should listen for changes only in a specifc folder, specify the folder Id in `ListenerConfiguration`.

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

### Logs on listner startup

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
