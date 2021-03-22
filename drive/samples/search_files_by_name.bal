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

###################################################################################
# Search files and folders
# ################################################################################
# More details : https://developers.google.com/drive/api/v3/reference/files/list
# https://developers.google.com/drive/api/v3/search-files
# 
#| What you want to query                                              |    Example                                                             |
#| --------------------------------------------------------------------|------------------------------------------------------------------------|
#|Files with the name "hello"					                       |     name = 'hello'                                                     |
#|Files with a name containing the words "hello" and "goodbye"	       |     name contains 'hello' and name contains 'goodbye'                  |
#|Files with a name that does not contain the word "hello"	           |     not name contains 'hello'                                          |   
#|Folders that are Google apps or have the folder MIME type	           |     mimeType = 'application/vnd.google-apps.folder'                    |
#|Files that are not folders					                       |     mimeType != 'application/vnd.google-apps.folder'                   |
#|Files that contain the text "important" and in the trash	           |     fullText contains 'important' and trashed = true                   |
#|Files that contain the word "hello"				                   |     fullText contains 'hello'                                          |
#|Files that do not have the word "hello"				               |     not fullText contains 'hello'                                      |
#|Files that contain the exact phrase "hello world"		               |     fullText contains '"hello world"'                                  |
#|Files with a query that contains the "" character (e.g., "\authors") |     fullText contains '\\authors'                                      |
#|Files with ID within a collection, e.g. parents collection	       |     '1234567' in parents                                               |
#|Files in an Application data folder in a collection	               |     'appDataFolder' in parents                                         |
#|Files for which user "test@example.org" has write permission	       |     'test@example.org' in writers                                      |
#|Files modified after a given date	                                   |      modifiedTime > '2012-06-04T12:00:00' // default time zone is UTC  |
#|Files shared with the authorized user with "hello" in the name	   |      sharedWithMe and name contains 'hello'                            |

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
    stream<drive:File>|error res = driveClient->getFilesByName("ballerina");
    // stream<drive:File>|error res = driveClient->getFilesByName("ballerina", 2);
    // stream<drive:File>|error res = driveClient->getFilesByName("ballerina", 2, "createdTime");
    if (res is stream<drive:File>){
        error? e = res.forEach(function (drive:File file) {
            json|error jsonObject = file.cloneWithType(json);
            if (jsonObject is json) {
                log:printInfo(jsonObject.toString());
            }
        });
    }
}
