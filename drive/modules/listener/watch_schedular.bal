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
import ballerina/lang.runtime;
import ballerinax/googleapis.drive as drive;

class Job {
    *task:Job;
    private HttpService httpService;
    private Listener httpListener;
    private drive:Client driveClient;
    private ListenerConfiguration config; 

    private boolean isWatchOnSpecificResource = false;
    private boolean isFolder = true;

    private WatchResponse watchResponse = {};
    private string channelUuid = EMPTY_STRING;
    private string specificFolderOrFileId = EMPTY_STRING;
    private string watchResourceId = EMPTY_STRING;
    private string currentToken = EMPTY_STRING;
    public decimal expiration = 0;
    
    private int retryCount = 1;
    private int retryScheduleCount = 1;
    private int retryMaxCount;
    private int retryInterval;
    private int leadTime;
    private int domainVerificationDelay;

    isolated function init(ListenerConfiguration config, drive:Client driveClient, 
                            Listener httpListener, HttpService httpService) {
        self.config = config;
        self.driveClient = driveClient;
        self.httpListener = httpListener;
        self.httpService = httpService;
        self.retryMaxCount = config?.channelRenewalConfig?.retryCount ?: 20;
        self.retryInterval = config?.channelRenewalConfig?.retryInterval ?: 100;
        self.leadTime = config?.channelRenewalConfig?.leadTime ?: 180;
        self.domainVerificationDelay = config?.channelRenewalConfig?.domainVerificationDelay ?: 300;
    }

    public isolated function execute() {
        error? err = self.registerWatchChannel();
        if (err is error) {
            if (self.retryCount == 1 && err.message().includes(ERR_UNAUTHORIZED_WEBHOOK_CHANNEL)){
                log:printInfo(CHANNEL_REGISTRATION_IN_PROGRESS 
                + " Waiting for " + self.domainVerificationDelay.toString() 
                + " seconds to check result.");
                log:printInfo(REQUEST_DOMAIN_VERIFICATION);
                runtime:sleep(<decimal>self.domainVerificationDelay);
                self.retryCount += 1;
                self.execute();
            } else if (err.message().includes(ERR_FILE_NOT_FOUND)){
                panic error(ERR_INVALID_FILE_OR_FOLDER, 'error = err);
            } else if (self.retryCount <= self.retryMaxCount) {
                log:printInfo(INFO_RETRY_CHANNEL_REGISTRATION + self.retryCount.toString());
                runtime:sleep(<decimal>self.retryInterval);
                self.retryCount += 1;
                self.execute();
            } else {
                panic error(ERR_CHANNEL_REGISTRATION, 'error = err);
            }
        } else {
            self.scheduleNextChannel();
        }
    }

    isolated function registerWatchChannel() returns error? {
       if (self.config.specificFolderOrFileId is string) {
            self.isFolder = check checkMimeType(self.driveClient, self.config.specificFolderOrFileId.toString());
       }
       if (self.config.specificFolderOrFileId is string && self.isFolder == true) {
            check validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), 
            self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = check watchFilesById(self.config.clientConfiguration, self.specificFolderOrFileId.toString(), 
            self.config.callbackURL);
            self.isWatchOnSpecificResource = true;
        } else if (self.config.specificFolderOrFileId is string && self.isFolder == false) {
            check validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), 
            self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = check watchFilesById(self.config.clientConfiguration, self.specificFolderOrFileId.toString(), 
            self.config.callbackURL);
            self.isWatchOnSpecificResource = true;
        } else {
            self.specificFolderOrFileId = EMPTY_STRING;
            self.watchResponse = check watchFiles(self.config.clientConfiguration, self.config.callbackURL);
        }
        self.channelUuid = self.watchResponse?.id.toString();
        self.currentToken = self.watchResponse?.startPageToken.toString();
        self.watchResourceId = self.watchResponse?.resourceId.toString();
        self.expiration = <decimal>self.watchResponse?.expiration;
        log:printInfo("Watch channel started in Google, id : " + self.channelUuid);

        self.httpService.channelUuid = self.channelUuid;
        self.httpService.watchResourceId = self.watchResourceId;
        self.httpService.currentToken = self.currentToken;

        self.httpListener.channelUuid = self.channelUuid;
        self.httpListener.watchResourceId = self.watchResourceId;
    }

    isolated function scheduleNextChannel() {
        error? err = self.scheduleNextChannelRenewal();
        if (err is error) {
            log:printWarn(WARN_CHANNEL_REGISTRATION, 'error = err);
            if (self.retryScheduleCount <= self.retryMaxCount) {
                log:printInfo(INFO_RETRY_SCHEDULE + self.retryScheduleCount.toString());
                runtime:sleep(<decimal>self.retryInterval);
                self.retryScheduleCount += 1;
                self.scheduleNextChannel();
            } else {
                panic error(ERR_SCHEDULE);
            }
        }
    }

    isolated function scheduleNextChannelRenewal() returns error? {
        time:Utc currentUtc = time:utcNow();
        decimal timeDifference = (self.expiration/1000) - (<decimal>currentUtc[0]) - <decimal>self.leadTime;
        time:Utc newTime = time:utcAddSeconds(currentUtc, timeDifference);
        time:Civil time = time:utcToCivil(newTime);
        log:printDebug("currentUtc : " + currentUtc.toString());
        log:printDebug("timeDifference : " + timeDifference.toString());
        log:printDebug("newTime : " + newTime.toString());

        task:JobId result = checkpanic task:scheduleOneTimeJob(new Job(self.config, self.driveClient, 
                                                    self.httpListener,self.httpService), time);
    }
}