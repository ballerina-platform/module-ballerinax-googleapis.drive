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
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_drive.'listener as listen;

configurable string callbackURL = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = drive:REFRESH_URL;
configurable string refreshToken = ?;

string fileId = "<FILE_ID_OF_THE_FILE_OR_FOLDER_TO_BE_DELETED>";
string parentFolderId = "<PLACE_FOLDER_ID_HERE>";

    drive:Configuration config = {
        clientConfig: {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshUrl: refreshUrl,
            refreshToken: refreshToken
        }
    };

    listen:ListenerConfiguration configuration = {
        port: 9090,
        callbackURL: callbackURL,
        clientConfiguration: config,
        specificFolderOrFileId : parentFolderId
    };

    listener listen:Listener gDrivelistener = new (configuration);

    service / on gDrivelistener {
        isolated remote function onFolderDeleteOnSpecificFolder(EventInfo folderId) returns error? {
            log:printInfo("Trigger > onFolderDeleteOnSpecificFolder > folderId : ", folderId);     
        }    
    }

public function main() returns error? {
    drive:Client driveClient = check new (config);
    boolean|error response = driveClient->deleteFile(fileId);
}
