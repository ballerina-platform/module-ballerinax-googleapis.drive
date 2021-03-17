// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/log;
import ballerina/test;
import nuwantissera/googleapis_drive as drive;

configurable string callbackURL = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = drive:REFRESH_URL;
configurable string refreshToken = ?;

drive:Configuration clientConfiguration = {clientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
}};

# Event Trigger class  
public class EventTrigger {
    
    public function onNewFolderCreatedEvent(string folderId) {
        log:print(TRIGGER_LOG + "New folder was created : " + folderId);
    }

    public function onFolderDeletedEvent(string folderID) {
        log:print(TRIGGER_LOG + "This folder was removed to the trashed : " + folderID);
    }

    public function onNewFileCreatedEvent(string fileId) {
        log:print(TRIGGER_LOG + "New File was created : " + fileId);
    }

    public function onFileDeletedEvent(string fileId) {
        log:print(TRIGGER_LOG + "This File was removed to the trashed : " + fileId);
    }

    public function onNewFileCreatedInSpecificFolderEvent(string fileId) {
        log:print(TRIGGER_LOG + "A file with Id " + fileId + " was created in side the folder specified");
    }

    public function onNewFolderCreatedInSpecificFolderEvent(string folderId) {
        log:print(TRIGGER_LOG + "A folder with Id " + folderId + " was created in side the folder specified");
    }

    public function onFolderDeletedInSpecificFolderEvent(string folderId) {
        log:print(TRIGGER_LOG + "A folder with Id " + folderId + " was deleted in side the folder specified");
    }

    public function onFileDeletedInSpecificFolderEvent(string fileId) {
        log:print(TRIGGER_LOG + "A file with Id " + fileId + " was deleted in side the folder specified");
    }
    public function onFileUpdateEvent(string fileId) {
        log:print(TRIGGER_LOG + "File updated : " + fileId);
    }
}

ListenerConfiguration congifuration = {
    port: 9090,
    callbackURL: callbackURL,
    clientConfiguration: clientConfiguration,
    eventService: new EventTrigger()
};

listener DriveEventListener gDrivelistener = new (congifuration);

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

@test:Config {enable: false}
function testDriveAPITrigger() {
    log:print("gDriveClient -> watchFiles()");
    int i = 0;
    while (true) {
        i = 0;
    }
    test:assertTrue(true, msg = "expected to be created a watch in google drive");
}
