// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/os;
import ballerinax/googleapis_drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

####################################################################################
# Filter files
# ##################################################################################
# Filtering can be done giving the filter string.
# This is also somewhat generalized function that accpets a filter string as the 
# paramter. 
# But if you want to do operations like, getfilebyname, there are specified functions
# availble for that.
# The filter string should be formatted string.
# Refer README.md for more information.
# ##################################################################################

string filterString = "<PLACE_QUERY_STRING>";

public function main() {
    drive:Configuration config = {
        clientConfig: {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshUrl: refreshUrl,
            refreshToken: refreshToken
        }
    };
    drive:Client driveClient = checkpanic new (config);
    stream<drive:File>|error response = driveClient->filterFiles(filterString);
    if (response is stream<drive:File>){
        error? e = response.forEach(isolated function (drive:File response) {
            log:printInfo(response?.id.toString());
        });
    } else {
        log:printError(response.message());
    }
}
