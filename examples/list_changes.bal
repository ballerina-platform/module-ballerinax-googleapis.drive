// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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
import ballerina/os;
import ballerinax/googleapis.drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

# ##################################################################################
# Get start page token and list changes in Drive since then
# ##################################################################################
# More details :
# https://developers.google.com/drive/api/v3/reference/changes/getStartPageToken
# https://developers.google.com/drive/api/v3/reference/changes/list
# ##################################################################################
public function main() returns error? {
    drive:ConnectionConfig config = {
        auth: {
            clientId,
            clientSecret,
            refreshUrl,
            refreshToken
        }
    };
    drive:Client driveClient = check new (config);

    string|error tokenResponse = driveClient->getStartPageToken();
    if tokenResponse is string {
        log:printInfo("Start page token: " + tokenResponse);
        stream<drive:Change>|error changesResponse = driveClient->listChanges(tokenResponse);
        if changesResponse is stream<drive:Change> {
            boolean foundChanges = false;
            changesResponse.forEach(function(drive:Change change) {
                foundChanges = true;
                log:printInfo(`Change detected for file ID: ${change.fileId}`);
            });
            if !foundChanges {
                log:printInfo("No changes found since token.");
            }
        } else {
            log:printError(changesResponse.message());
        }
    } else {
        log:printError(tokenResponse.message());
    }
}
