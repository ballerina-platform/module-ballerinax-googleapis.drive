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
import ballerinax/googleapis.drive as drive;

isolated service class HttpService {
    *http:Service;
    private string channelUuid;
    private string currentToken;
    private string watchResourceId;
    private json[] currentFileStatus = [];
    private final ListenerConfiguration & readonly config;
    private final string specificFolderOrFileId;
    private final drive:ConnectionConfig & readonly driveConfig;
    private final boolean isWatchOnSpecificResource;
    private final boolean isFolder;
    private final HttpToGDriveAdaptor adaptor;
    private final MethodNames & readonly methods;
    private final string domainVerificationFileContent;

    isolated function init(HttpToGDriveAdaptor adaptor, string channelUuid, string currentToken, string watchResourceId, 
                            ListenerConfiguration config, boolean isWatchOnSpecificResource, boolean isFolder, 
                            string specificFolderOrFileId, string domainVerificationFileContent) {
        self.adaptor = adaptor;
        self.channelUuid = channelUuid;
        self.currentToken = currentToken;
        self.watchResourceId = watchResourceId;
        self.driveConfig = config.clientConfiguration.cloneReadOnly();
        self.config = config.cloneReadOnly();
        self.isFolder = isFolder;
        self.isWatchOnSpecificResource = isWatchOnSpecificResource;
        self.specificFolderOrFileId = specificFolderOrFileId;
        self.domainVerificationFileContent = domainVerificationFileContent;

        string[] methodNames = adaptor.getServiceMethodNames();
        self.methods = {
            isOnNewFileCreate: isMethodAvailable("onFileCreate", methodNames),
            isOnNewFolderCreate: isMethodAvailable("onFolderCreate", methodNames),
            isOnFileUpdate: isMethodAvailable("onFileUpdate", methodNames),
            isOnFolderUpdate: isMethodAvailable("onFolderUpdate", methodNames),
            isOnDelete: isMethodAvailable("onDelete", methodNames),
            isOnFileTrash: isMethodAvailable("onFileTrash", methodNames),
            isOnFolderTrash: isMethodAvailable("onFolderTrash", methodNames)
        };

        if (methodNames.length() > 0) {
            foreach string methodName in methodNames {
                log:printError("Unrecognized method [" + methodName + "] found in user implementation."); 
            }
        }     
    }

    public isolated function setChannelUuid (string channelUuid) {
        lock {
            self.channelUuid = channelUuid;
        } 
    }

    public isolated function setCurrentToken (string currentToken) {
        lock {
            self.currentToken = currentToken;
        }  
    }

    public isolated function setWatchResourceId(string watchResourceId) {
        lock {
            self.watchResourceId = watchResourceId;
        }  
    }

    public isolated function getChannelUuid() returns string {
        lock {
            return self.channelUuid;
        } 
    }

    public isolated function getCurrentToken() returns string {
        lock {
            return self.currentToken;
        } 
    }

    resource isolated function post events(http:Caller caller, http:Request request) returns @tainted error? {
        if (check request.getHeader(GOOGLE_CHANNEL_ID) != self.getChannelUuid() ){
            fail error("Different channel IDs found, Resend the watch request");
        } else {
            ChangesListResponse[] response = check getAllChangeList(self.getCurrentToken(), self.config);
            foreach ChangesListResponse item in response {
                self.setCurrentToken(item?.newStartPageToken.toString());
                if (self.isWatchOnSpecificResource && self.isFolder) {
                    log:printDebug("Folder watch response processing");
                    check mapEventForSpecificResource(<@untainted> self.specificFolderOrFileId, <@untainted> item, 
                            <@untainted> self.driveConfig, <@untainted> self.adaptor, self.methods);
                } else if (self.isWatchOnSpecificResource && self.isFolder == false) {
                    log:printDebug("File watch response processing");
                    check mapFileUpdateEvents(self.specificFolderOrFileId, item, self.driveConfig, self.adaptor, 
                            self.methods);
                } else {
                    log:printDebug("Whole drive watch response processing");
                    check mapEvents(<@untainted>item, <@untainted>self.driveConfig, <@untainted>self.adaptor, 
                                    <@untainted>self.methods);
                }
            } 
            check caller->respond(http:STATUS_OK);
        }
    }

    // Resource function required for domain verification by Google
    resource isolated function get [string name](http:Caller caller) returns @tainted error? {
        http:Response r = new();
        if(self.domainVerificationFileContent.length() < 100 && 
                self.domainVerificationFileContent.startsWith(GOOGLE_SITE_VERIFICATION_PREFIX)){
            r.setHeader(CONTENT_TYPE, "text/html; charset=UTF-8");
            r.setTextPayload(self.domainVerificationFileContent);
            log:printDebug("Domain verification on process");
        } else {
            fail error("Invalid input for domain verification");
        }
        check caller->respond(r);
    }
}

# Retrieves whether the particular remote method is available.
#
# + methodName - Name of the required method
# + methods - All available methods
# + return - `true` if method available or else `false`
isolated function isMethodAvailable(string methodName, string[] methods) returns boolean {
    boolean isAvailable = methods.indexOf(methodName) is int;
    if (isAvailable) {
        var index = methods.indexOf(methodName);
        if (index is int) {
            _ = methods.remove(index);
        }
    }
    return isAvailable;
}
