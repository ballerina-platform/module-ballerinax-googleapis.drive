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
import ballerina/http;
import ballerinax/googleapis_drive as drive;

service class HttpService {
    
    public string channelUuid;
    public string currentToken;
    public string watchResourceId;
    public json[] currentFileStatus = [];
    public string specificFolderOrFileId;
    public drive:Client driveClient;
    public boolean isWatchOnSpecificResource;
    public boolean isAFolder = true;

    private SimpleHttpService httpService;

    public isolated function init(SimpleHttpService httpService, string channelUuid, string currentToken, 
                                    string watchResourceId, drive:Client driveClient, boolean isWatchOnSpecificResource, 
                                    boolean isAFolder,string specificFolderOrFileId) {
        self.httpService = httpService;
        self.channelUuid = channelUuid;
        self.currentToken = currentToken;
        self.watchResourceId = watchResourceId;
        self.driveClient = driveClient;
        self.isAFolder = isAFolder;
        self.isWatchOnSpecificResource = isWatchOnSpecificResource;
        self.specificFolderOrFileId = specificFolderOrFileId;
    }

    resource isolated function post events(http:Caller caller, http:Request request) returns error? {
        if(check request.getHeader(GOOGLE_CHANNEL_ID) != self.channelUuid){
            fail error("Diffrent channel IDs found, Resend the watch request");
        } else {
            drive:ChangesListResponse[] response = check getAllChangeList(self.currentToken, self.driveClient);
            foreach drive:ChangesListResponse item in response {
                self.currentToken = item?.newStartPageToken.toString();
                if (self.isWatchOnSpecificResource && self.isAFolder) {
                    log:printDebug("Folder watch response processing");
                    check mapEventForSpecificResource(<@untainted> self.specificFolderOrFileId, <@untainted> item, 
                    <@untainted> self.driveClient, <@untainted> self.httpService);
                } else if (self.isWatchOnSpecificResource && self.isAFolder == false) {
                    log:printDebug("File watch response processing");
                    check mapFileUpdateEvents(self.specificFolderOrFileId, item, self.driveClient, self.httpService);
                } else {
                    log:printDebug("Whole drive watch response processing");
                    check mapEvents(item, self.driveClient, self.httpService);
                }
            } 
            check caller->respond(http:STATUS_OK);
        }
    }
}



