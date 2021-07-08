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

import ballerina/log;
import ballerinax/googleapis.drive as drive;
import ballerinax/googleapis.drive.'listener as listen;

configurable string callbackURL = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = drive:REFRESH_URL;
configurable string refreshToken = ?;
configurable string domainVerificationFileContent = ?;

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
    domainVerificationFileContent : domainVerificationFileContent
};

listener listen:Listener gDrivelistener = new (configuration);

service / on gDrivelistener {
    remote function onFileCreate(listen:Change event) returns error? {
        _ = @strand { thread: "any" } start userLogic(event);
    }
}

function userLogic(listen:Change event) returns error? {
    // Write your logic here
}
