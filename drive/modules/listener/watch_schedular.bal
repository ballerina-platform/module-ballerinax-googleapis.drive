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
    private int? expiration = 0;

    public isolated function execute() {
        decimal expiration = <decimal>self.config.expiration;
        if (self.config.specificFolderOrFileId is string) {
            self.isFolder = checkpanic checkMimeType(self.driveClient, self.config.specificFolderOrFileId.toString());
        }
       if (self.config.specificFolderOrFileId is string && self.isFolder == true) {
            checkpanic validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), 
            self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = checkpanic startWatch(self.config.callbackURL, self.driveClient, 
            self.specificFolderOrFileId.toString());
            self.isWatchOnSpecificResource = true;
            if(expiration > MAX_EXPIRATION_TIME_FOR_FILE_RESOURCE){
                expiration = MAX_EXPIRATION_TIME_FOR_FILE_RESOURCE;
            }
        } else if (self.config.specificFolderOrFileId is string && self.isFolder == false) {
            checkpanic validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), 
            self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = checkpanic startWatch(self.config.callbackURL, self.driveClient, 
            self.specificFolderOrFileId);
            self.isWatchOnSpecificResource = true;
            if(expiration > MAX_EXPIRATION_TIME_FOR_FILE_RESOURCE){
                expiration = MAX_EXPIRATION_TIME_FOR_FILE_RESOURCE;
            }
        } else {
            self.specificFolderOrFileId = EMPTY_STRING;
            self.watchResponse = checkpanic startWatch(self.config.callbackURL, self.driveClient);
            if(expiration > MAX_EXPIRATION_TIME_FOR_CHANGES_ALL_DRIVE){
                expiration = MAX_EXPIRATION_TIME_FOR_CHANGES_ALL_DRIVE;
            }
        }
        self.channelUuid = self.watchResponse?.id.toString();
        self.currentToken = self.watchResponse?.startPageToken.toString();
        self.watchResourceId = self.watchResponse?.resourceId.toString();
        log:printInfo("Watch channel started in Google, id : " + self.channelUuid);

        self.httpService.channelUuid = self.channelUuid;
        self.httpService.watchResourceId = self.watchResourceId;
        self.httpService.currentToken = self.currentToken;

        self.httpListener.channelUuid = self.channelUuid;
        self.httpListener.watchResourceId = self.watchResourceId;

        time:Utc currentUtc = time:utcNow();
        time:Utc newTime = time:utcAddSeconds(currentUtc, expiration);
        time:Civil time = time:utcToCivil(newTime);

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
