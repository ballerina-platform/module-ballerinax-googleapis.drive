// Copyright (c) 2025 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerinax/googleapis.drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

// Replace with the ID of a Google Docs/Sheets/Slides file
string fileId = "<PLACE_YOUR_FILE_ID_HERE>";

# ##################################################################################
# Export Google Drive file to another MIME type (e.g., MARKDOWN)
# ##################################################################################
# More details : https://developers.google.com/drive/api/v3/reference/files/export
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

    // MIME type for export (e.g., MARKDOWN)
    string exportMimeType = "text/markdown";
    drive:FileContent|error response = driveClient->exportFile(fileId, exportMimeType);
    if (response is drive:FileContent) {
        log:printInfo("Exported file content: " + response.toString());
    } else {
        log:printError("Error exporting file: " + response.message());
    }
}
