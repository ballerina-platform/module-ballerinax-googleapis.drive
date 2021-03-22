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

drive:UpdateFileMetadataOptional optionalsFileMetadata = {
    addParents : "<GIVE_PARENT_FOLDER_ID>"
};
drive:File payloadFileMetadata = {
    name : "<GIVE_THE_FILE_NAME>",
    mimeType : "<GIVE_MIME_TYPE>",
    description : "<GIVE_THE_DESCRIPTION>"
};

string fileId = "<PLACE_YOUR_FILE_ID_HERE>";

###################################################################################
# Update file with metadata
###################################################################################
# Update a file with any metadata that is supported by the Drive API.
# e.g :You can update the description of a file, MIME type of a file..
# This function is a more generalized function to update a file.
# You can use this method to do many updates at once.
# But if you want to do only one change, You can use other specified functions also.
# E.g : If you want to rename/move a file. There are specified functions.
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
    drive:File|error res = driveClient->updateFileMetadataById(fileId, payloadFileMetadata, optionalsFileMetadata);
    //Print file ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:printInfo(id);
    } else {
        log:printError(res.message());
    }  
}
