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

string fileId = "<PLACE_YOUR_FILE_ID_HERE>";

###################################################################################
# Delete file by ID
###################################################################################
# Permanently deletes a file owned by the user without moving it to the trash. 
# If the file belongs to a shared drive the user must be an organizer on the parent. 
# If the target is a folder, all descendants owned by the user are also deleted.
# ################################################################################
# More details : https://developers.google.com/drive/api/v3/reference/files/delete
# #################################################################################

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
    //Do not supply a request body with this method.
    //If successful, this method returns an empty response body.
    boolean|error res = driveClient->deleteFile(fileId);
    if(res is boolean){
        log:printInfo("File Deleted");
    } else {
        log:printError(res.message());
    }
}
