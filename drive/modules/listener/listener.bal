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
import ballerinax/googleapis.drive as drive;
import ballerina/task;
import ballerina/time;

# Listener Configuration. 
#
# + port - Port for the listener.  
# + specificFolderOrFileId - Folder or file Id.  
# + domainVerificationFileContent - File content of HTML file used in domain verification.
# + callbackURL - Callback URL registered.  
# + clientConfiguration - Drive client connecter configuration.
# + channelRenewalConfig - Channel renewal configuration.
@display{label: "Listener Config"}
public type ListenerConfiguration record {
    @display{label: "Port"}
    int port;
    @display{label: "Callback URL"}
    string callbackURL;
    @display{label: "Domain Verification File Content"}
    string domainVerificationFileContent;
    drive:ConnectionConfig clientConfiguration;
    @display{label: "Specific Folder ID"}
    string? specificFolderOrFileId = ();
    ChannelRenewalConfig channelRenewalConfig?;
};

# Channel Renewal Configuration
#
# + retryCount - Maximum number of reties allowed to renew listener channel in seconds. (default : 20s)
# + retryInterval - Time between retries to renew listener channel in seconds. (default: 100s)  
# + leadTime - Time prior to expiration that renewal should happen happen. (default: 180s) 
# + domainVerificationDelay - Initial wait time for domain verification check in seconds. (default: 300s)  
@display{label: "Channel Renewal Config"}
public type ChannelRenewalConfig record {
    @display{label: "Retry Count"}
    int retryCount?;
    @display{label: "Retry Interval"}
    int retryInterval?;
    @display{label: "Lead Time"}
    int leadTime?;
    @display{label: "Domain Verification Delay"}
    int domainVerificationDelay?;
};

# Drive event listener   
@display {label: "Google Drive Listener", iconPath: "resources/googleapis.drive.svg"}
public class Listener {
    # Watch Channel ID
    public string channelUuid = EMPTY_STRING;
    # Watch Resource ID
    public string watchResourceId = EMPTY_STRING;
    private string currentToken = EMPTY_STRING;
    private string specificFolderOrFileId = EMPTY_STRING;
    private drive:Client driveClient;
    private WatchResponse watchResponse;
    private boolean isWatchOnSpecificResource = false;
    private boolean isFolder = true;
    private ListenerConfiguration config;
    private http:Listener httpListener;
    private HttpService? httpService;
    private string domainVerificationFileContent;

    # Initializes Google Drive connector listener.
    # 
    # + config - Listener configuration
    # + return - An error on failure of initialization or else `()`
    public isolated function init(ListenerConfiguration config) returns @tainted error? {
        self.httpListener = check new (config.port);
        self.driveClient = check new (config.clientConfiguration);
        self.config = config;
        self.domainVerificationFileContent = config.domainVerificationFileContent;
        self.httpService = ();
    }

    public isolated function attach(SimpleHttpService s, string[]|string? name = ()) returns error? {
        HttpToGDriveAdaptor adaptor = check new (s);
        HttpService currentHttpService = new (adaptor, self.channelUuid, self.currentToken, self.watchResourceId, 
                                            self.config, self.isWatchOnSpecificResource, self.isFolder, 
                                            self.specificFolderOrFileId, self.domainVerificationFileContent);
        self.httpService = currentHttpService;
        check self.httpListener.attach(currentHttpService, name);
    
        time:Utc currentUtc = time:utcNow();
        time:Civil time = time:utcToCivil(currentUtc);
        _ = check task:scheduleOneTimeJob(new Job(self.config, self.driveClient, self, currentHttpService), time);
    }

    public isolated function 'start() returns error? {
        check self.httpListener.'start();
    }

    public isolated function detach(service object {} s) returns @tainted error? {
        check stopWatchChannel(self.config, self.channelUuid, self.watchResourceId);
        log:printDebug("Unsubscribed from the watch channel ID : " + self.channelUuid);
        HttpService? currentHttpService = self.httpService;
        if currentHttpService is HttpService {
            return self.httpListener.detach(currentHttpService);
        }
    }

    public isolated function gracefulStop() returns @tainted error? {
        check stopWatchChannel(self.config, self.channelUuid, self.watchResourceId);
        log:printDebug("Unsubscribed from the watch channel ID : " + self.channelUuid);
        return self.httpListener.gracefulStop();
    }

    public isolated function immediateStop() returns @tainted error? {
        check stopWatchChannel(self.config, self.channelUuid, self.watchResourceId);
        log:printDebug("Unsubscribed from the watch channel ID : " + self.channelUuid);
        return self.httpListener.immediateStop();
    }
}