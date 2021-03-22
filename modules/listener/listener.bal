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
import nuwantissera/googleapis_drive as drive;

# Listener Configuration. 
#
# + port - Port for the listener.  
# + specificFolderOrFileId - Folder or file Id.  
# + callbackURL - Callback URL registered.   
# + clientConfiguration - Drive client connecter configuration.  
# + eventService - 'OnEventService' object with supported events. 
public type ListenerConfiguration record {
    int port;
    string callbackURL;
    drive:Configuration clientConfiguration;
    OnEventService eventService;
    string? specificFolderOrFileId = ();
};

# Drive event listener   
@display {label: "Google Drive Listener"}
public class DriveEventListener {
    private http:Listener httpListener;
    private string currentToken;
    private string channelUuid;
    private string watchResourceId;
    private http:Client clientEP;
    private OnEventService eventService;
    private json[] currentFileStatus = [];
    private string specificFolderOrFileId;
    private drive:Client driveClient;
    private drive:WatchResponse watchResponse;
    private boolean isWatchOnSpecificResource = false;
    private boolean isAFolder = true;

    # Listener initialization
    public function init(ListenerConfiguration config) returns @tainted error? {
        self.eventService = config.eventService;
        self.httpListener = check new (config.port);
        self.driveClient = check new (config.clientConfiguration);
        if (config.specificFolderOrFileId is string) {
            self.isAFolder = check checkMimeType(self.driveClient, config.specificFolderOrFileId.toString());
        }
        if (config.specificFolderOrFileId is string && self.isAFolder == true) {
            check validateSpecificFolderExsistence(config.specificFolderOrFileId.toString(), self.driveClient);
            self.specificFolderOrFileId = config.specificFolderOrFileId.toString();
            self.watchResponse = check startWatch(config.callbackURL, self.driveClient, self.specificFolderOrFileId.
            toString());
            check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus, 
            self.specificFolderOrFileId.toString());
            self.isWatchOnSpecificResource = true;
        } else if (config.specificFolderOrFileId is string && self.isAFolder == false) {
            check validateSpecificFolderExsistence(config.specificFolderOrFileId.toString(), self.driveClient);
            self.specificFolderOrFileId = config.specificFolderOrFileId.toString();
            self.watchResponse = check startWatch(config.callbackURL, self.driveClient, self.specificFolderOrFileId);
            self.isWatchOnSpecificResource = true;
            check getCurrentStatusOfFile(self.driveClient, self.currentFileStatus, self.specificFolderOrFileId);
        } else {
            self.specificFolderOrFileId = EMPTY_STRING;
            self.watchResponse = check startWatch(config.callbackURL, self.driveClient);
            check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus);
        }
        self.channelUuid = self.watchResponse?.id.toString();
        self.currentToken = self.watchResponse?.startPageToken.toString();
        self.watchResourceId = self.watchResponse?.resourceId.toString();
        log:print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        log:print("Watch channel started in Google, id : " + self.channelUuid);
        log:print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }
    
    public isolated function attach(http:Service s, string[]|string? name) returns error? {
        return self.httpListener.attach(s, name);
    }

    public isolated function detach(http:Service s) returns error? {
        return self.httpListener.detach(s);
    }

    public isolated function 'start() returns error? {
        return self.httpListener.'start();
    }

    public isolated function gracefulStop() returns error? {
        return ();
    }

    public isolated function immediateStop() returns error? {
        return self.httpListener.immediateStop();
    }

    # Finding event type triggered and retrieve changes list.
    # 
    # + caller - The http caller object for responding to requests 
    # + request - The HTTP request.
    # + return - Returns error, if unsuccessful.
    public function findEventType(http:Caller caller, http:Request request) returns @tainted error? {
        log:print("<<<<<<<<<<<<<<< RECEIVING A CALLBACK <<<<<<<<<<<<<<<");
        string channelID = check request.getHeader("X-Goog-Channel-ID");
        string messageNumber = check request.getHeader("X-Goog-Message-Number");
        string resourceStates = check request.getHeader("X-Goog-Resource-State");
        string channelExpiration = check request.getHeader("X-Goog-Channel-Expiration");
        if (channelID != self.channelUuid) {
            fail error("Diffrent channel IDs found, Resend the watch request");
        } else {
            drive:ChangesListResponse[] response = check getAllChangeList(self.currentToken, self.driveClient);
            foreach drive:ChangesListResponse item in response {
                self.currentToken = item?.newStartPageToken.toString();
                if (self.isWatchOnSpecificResource && self.isAFolder) {
                    log:print("Folder watch response processing");
                    check mapEventForSpecificResource(<@untainted> self.specificFolderOrFileId, <@untainted> item, 
                    <@untainted> self.driveClient, <@untainted> self.eventService, <@untainted> self.currentFileStatus);
                    check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus, self.specificFolderOrFileId);
                } else if (self.isWatchOnSpecificResource && self.isAFolder == false) {
                    log:print("File watch response processing");
                    check mapFileUpdateEvents(self.specificFolderOrFileId, item, self.driveClient, self.eventService, 
                    self.currentFileStatus);
                    check getCurrentStatusOfFile(self.driveClient, self.currentFileStatus, self.specificFolderOrFileId);
                } else {
                    log:print("Whole drive watch response processing");
                    check mapEvents(item, self.driveClient, self.eventService, self.currentFileStatus);
                    check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus);
                }
            }
        }
        log:print("<<<<<<<<<<<<<<< RECEIVED >>>>>>>>>>>>>>>");
    }

    # Stop all subscriptions for listening.
    # 
    # + return - Returns error, if unsuccessful.
    public function stopWatchChannel() returns @tainted error? {
        boolean|error response = self.driveClient->watchStop(self.channelUuid, self.watchResourceId);
        if (response is boolean) {
            log:print("Watch channel stopped");
        } else {
            log:print("Watch channel was not stopped");
            return response;
        }
    }
}
