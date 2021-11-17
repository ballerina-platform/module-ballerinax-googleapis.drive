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
string domainVerificationFileContent = os:getEnv("DOMAIN_VERIFICATION_FILE_CONTENT");

drive:ConnectionConfig clientConfiguration = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
    }
};

ListenerConfiguration configuration = {
    port: 9090,
    callbackURL: callbackURL,
    clientConfiguration: clientConfiguration,
    domainVerificationFileContent : domainVerificationFileContent
};

listener Listener gDriveListener = new (configuration);

service / on gDriveListener {
    // isolated remote function onFileCreate(Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFileCreate > changeInfo : " + changeInfo.toString());     
    // }
    // isolated remote function onFolderCreate(Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFolderCreate > changeInfo : " + changeInfo.toString());     
    // }
    // isolated remote function onFileUpdate(Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFileUpdate > changeInfo : " + changeInfo.toString());     
    // }
    // isolated remote function onFolderUpdate(Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFolderUpdate > changeInfo : " + changeInfo.toString());     
    // }
    // isolated remote function onFileTrash(Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFileTrash > changeInfo : " + changeInfo.toString());     
    // }
    // isolated remote function onFolderTrash(Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onFolderTrash > changeInfo : " + changeInfo.toString());     
    // }
    // isolated remote function onDelete(Change changeInfo) returns error? {
    //     log:printInfo("Trigger > onPermanentDelete > changeInfo : " + changeInfo.toString());     
    // }
}

@test:Config {enable: false}
public isolated function testDriveAPITrigger() {
    log:printInfo("gDriveClient -> watchFiles()");
    int i = 0;
    while (true) {
        i = 0;
    }
}
