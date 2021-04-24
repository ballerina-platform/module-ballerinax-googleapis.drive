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

import ballerina/log;
import ballerina/task;
import ballerina/time;
import ballerinax/googleapis_drive as drive;

class Job {
    *task:Job;
    private SimpleHttpService s;
    private HttpService httpService;
    private Listener httpListener;
    private drive:Client driveClient;
    private ListenerConfiguration config; 

    private boolean isWatchOnSpecificResource = false;
    private boolean isFolder = true;

    private drive:WatchResponse watchResponse;
    private string channelUuid = EMPTY_STRING;
    private string specificFolderOrFileId = EMPTY_STRING;
    private string watchResourceId = EMPTY_STRING;
    private string currentToken = EMPTY_STRING;
    public decimal expiration = 0;

    public isolated function execute() {
        log:printInfo("Expiration time : " + self.expiration.toString());
        if (self.config.specificFolderOrFileId is string) {
            self.isFolder = checkpanic checkMimeType(self.driveClient, self.config.specificFolderOrFileId.toString());
        }
       if (self.config.specificFolderOrFileId is string && self.isFolder == true) {
            checkpanic validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), 
            self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = checkpanic self.driveClient->watchFilesById(self.specificFolderOrFileId.toString(), 
            self.config.callbackURL);
            self.isWatchOnSpecificResource = true;
        } else if (self.config.specificFolderOrFileId is string && self.isFolder == false) {
            checkpanic validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), 
            self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = checkpanic self.driveClient->watchFilesById(self.specificFolderOrFileId.toString(), 
            self.config.callbackURL);
            self.isWatchOnSpecificResource = true;
        } else {
            self.specificFolderOrFileId = EMPTY_STRING;
            self.watchResponse = checkpanic self.driveClient->watchFiles(self.config.callbackURL);
        }
        self.channelUuid = self.watchResponse?.id.toString();
        self.currentToken = self.watchResponse?.startPageToken.toString();
        self.watchResourceId = self.watchResponse?.resourceId.toString();
        self.expiration = <decimal>self.watchResponse?.expiration;
        log:printInfo("Watch channel started in Google, id : " + self.channelUuid);
        log:printInfo("Expiration time : " + self.expiration.toString());

        self.httpService.channelUuid = self.channelUuid;
        self.httpService.watchResourceId = self.watchResourceId;
        self.httpService.currentToken = self.currentToken;

        self.httpListener.channelUuid = self.channelUuid;
        self.httpListener.watchResourceId = self.watchResourceId;

        time:Utc currentUtc = time:utcNow();
        decimal timeDifference = (self.expiration/1000) - (<decimal>currentUtc[0]) - 60;
        time:Utc newTime = time:utcAddSeconds(currentUtc, timeDifference);
        time:Civil time = time:utcToCivil(newTime);
        log:printInfo("currentUtc : " + currentUtc.toString());
        log:printInfo("timeDifference : " + timeDifference.toString());
        log:printInfo("newTime : " + newTime.toString());

        task:JobId result = checkpanic task:scheduleOneTimeJob(new Job(self.config, self.driveClient, self.httpListener, 
            self.httpService), time);
    }

    isolated function init(ListenerConfiguration config, drive:Client driveClient, Listener httpListener, 
                           HttpService httpService) {
        self.config = config;
        self.driveClient = driveClient;
        self.httpListener = httpListener;
        self.httpService = httpService;
    }
}
