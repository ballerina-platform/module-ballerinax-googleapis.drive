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

string fileName = "<NEW_FILE_NAME>";

###################################################
# Upload file using Byte Array
# #################################################
# You can set byte array as the source and upload. 
# #################################################

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
    byte[] byteArray = [116,101,115,116,45,115,116,114,105,110,103];
    drive:File|error res = driveClient->uploadFileUsingByteArray(byteArray, fileName);
    // drive:File|error res = driveClient->uploadFileUsingByteArray(byteArray, fileName, parentFolderId);
    //Print file ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:printInfo(id);
    } else {
        log:printError(res.message());
    }
}
