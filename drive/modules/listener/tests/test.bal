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
import ballerinax/googleapis_drive as drive;

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
    // expiration: 866500000000,
    // specificFolderOrFileId: "1A1oEfuP7gZrCUU6FySahMvjpqJP-mDEn"
    // specificFolderOrFileId:"1qkopkT7g_KAJX1TKJir7NLRQ9mYNBcv8DWAaD17FbMo"
};

listener Listener gDriveListener = new (congifuration);

service / on gDriveListener {
    isolated remote function onFileCreate(EventInfo fileId) returns error? {
        log:printInfo("Trigger > onFileCreate > fileID : ", fileId);     
    }
    isolated remote function onFolderCreate(EventInfo folderId) returns error? {
        log:printInfo("Trigger > onFolderCreate > fileID : ", folderId);     
    }
    isolated remote function onFileUpdate(EventInfo fileId) returns error? {
        log:printInfo("Trigger > onFileUpdate > fileID : ", fileId);     
    }
    isolated remote function onFolderUpdate(EventInfo folderId) returns error? {
        log:printInfo("Trigger > onFolderUpdate > folderId : ", folderId);     
    }
    isolated remote function onTrash(EventInfo fileId) returns error? {
        log:printInfo("Trigger > onTrash > fileID : ", fileId);     
    }
    isolated remote function onDelete(EventInfo fileId) returns error? {
        log:printInfo("Trigger > onPermenantDelete > fileOrFolderId : ", fileId);     
    }
}

@test:Config {enable: true}
public isolated function testDriveAPITrigger() {
    log:printInfo("gDriveClient -> watchFiles()");
    int i = 0;
    while (true) {
        i = 0;
    }
    test:assertTrue(true, msg = "expected to be created a watch in google drive");
}
