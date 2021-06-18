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
# + dnsVerificationFileContent - File content of HTML file used in domain verification.
# + callbackURL - Callback URL registered.  
# + clientConfiguration - Drive client connecter configuration.
public type ListenerConfiguration record {
    int port;
    string callbackURL;
    string dnsVerificationFileContent;
    Configuration clientConfiguration;
    string? specificFolderOrFileId = ();
};

# Represents configuration parameters to create Google drive Client.
#
# + secureSocketConfig - Represents OAuth2 direct token configurations for OAuth2 authentication 
# + clientConfig - Provides configurations for facilitating secure communication with a remote HTTP endpoint  
@display{label: "Connection Config"}
public type Configuration record {
    @display{label: "Auth Config"}
    http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig clientConfig; 
    @display{label: "SSL Config"}
    http:ClientSecureSocket secureSocketConfig?;
};

# Drive event listener   
@display {label: "Google Drive Listener"}
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
    private HttpService httpService;
    private string dnsVerificationFileContent;

    public isolated function init(ListenerConfiguration config) returns @tainted error? {
        self.httpListener = check new (config.port);
        self.driveClient = check new (config.clientConfiguration);
        self.config = config;
        self.dnsVerificationFileContent = config.dnsVerificationFileContent;
    }

    public isolated function attach(SimpleHttpService s, string[]|string? name = ()) returns error? {
        self.httpService = new HttpService(s, self.channelUuid, self.currentToken, self.watchResourceId, 
                                            self.driveClient, self.config, self.isWatchOnSpecificResource, 
                                            self.isFolder, self.specificFolderOrFileId, self.dnsVerificationFileContent);
        check self.httpListener.attach(self.httpService, name);
    
        time:Utc currentUtc = time:utcNow();
        time:Civil time = time:utcToCivil(currentUtc);
        task:JobId result = check task:scheduleOneTimeJob(new Job(self.config, self.driveClient, self, self.httpService), time);
    }

    public isolated function 'start() returns error? {
        check self.httpListener.'start();
    }

    public isolated function detach(service object {} s) returns @tainted error? {
        check stopWatchChannel(self.config, self.channelUuid, self.watchResourceId);
        log:printDebug("Unsubscribed from the watch channel ID : " + self.channelUuid);
        return self.httpListener.detach(s);
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

