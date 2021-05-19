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
import ballerina/os;
import ballerina/test;
import ballerinax/googleapis.drive as drive;

string callbackURL = os:getEnv("CALLBACK_URL");
string clientId = os:getEnv("CLIENT_ID");
string clientSecret = os:getEnv("CLIENT_SECRET");
string refreshUrl = drive:REFRESH_URL;
string refreshToken = os:getEnv("REFRESH_TOKEN");

drive:Configuration clientConfiguration = {clientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
}};

ListenerConfiguration congifuration = {
    port: 9090,
    callbackURL: callbackURL,
    clientConfiguration: clientConfiguration
};

listener Listener gDriveListener = new (congifuration);

service / on gDriveListener {
    // isolated remote function onFileCreate(drive:Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFileCreate > changeInfo : ", changeInfo);     
    // }
    // isolated remote function onFolderCreate(drive:Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFolderCreate > changeInfo : ", changeInfo);     
    // }
    // isolated remote function onFileUpdate(drive:Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFileUpdate > changeInfo : ", changeInfo);     
    // }
    // isolated remote function onFolderUpdate(drive:Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFolderUpdate > changeInfo : ", changeInfo);     
    // }
    // isolated remote function onFileTrash(drive:Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFileTrash > changeInfo : ", changeInfo);     
    // }
    // isolated remote function onFolderTrash(drive:Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFolderTrash > changeInfo : ", changeInfo);     
    // }
    // isolated remote function onDelete(drive:Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onPermenantDelete > changeInfo : ", changeInfo);     
    // }
}

@test:Config {enable: false}
public isolated function testDriveAPITrigger() {
    log:printInfo("gDriveClient -> watchFiles()");
    int i = 0;
    while (true) {
        i = 0;
    }
    test:assertTrue(true, msg = "expected to be created a watch in google drive");
}
