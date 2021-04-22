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

string folderName = "<FOLDER_NAME>";

###################################################################################
# Create folder 
###################################################################################
# Creates a new folder
# Specify the file Name inside the payload. Else it will be uploaded as Untitled 
# folder.
# Specify the mime type as application/vnd.google-apps.folder
# More details : https://developers.google.com/drive/api/v3/mime-types
# ################################################################################
# More details : https://developers.google.com/drive/api/v3/reference/files/create
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
    drive:File|error res = driveClient->createFolder(folderName);
    // drive:File|error response = driveClient->createFolder(folderName, parentFolderId);
    //Print folder ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:printInfo(id);
    } else {
        log:printError(res.message());
    }
}
