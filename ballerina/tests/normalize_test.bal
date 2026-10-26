// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/test;

// Offline tests: Drive returns int64 fields as JSON strings.

@test:Config {}
function testFileInt64FieldsAsStrings() returns error? {
    json payload = {
        id: "f1",
        size: "12345",
        quotaBytesUsed: "12345",
        'version: "7",
        thumbnailVersion: "3",
        appProperties: {size: "keep-me"}
    };
    File file = check normalizeFileJson(payload).cloneWithType(File);
    test:assertEquals(file?.size, 12345);
    test:assertEquals(file?.quotaBytesUsed, 12345);
    test:assertEquals(file?.'version, 7);
    test:assertEquals(file?.thumbnailVersion, 3);
    test:assertEquals(file?.appProperties, {size: "keep-me"});
}

@test:Config {}
function testFileInt64FieldsAlreadyNumeric() returns error? {
    File file = check normalizeFileJson({id: "f1", size: 10}).cloneWithType(File);
    test:assertEquals(file?.size, 10);
}

@test:Config {}
function testFileListAndChangeListNormalization() returns error? {
    FilesResponse files = check normalizeFileListJson({
        kind: "drive#fileList",
        files: [{id: "a", size: "1"}, {id: "b"}]
    }).cloneWithType(FilesResponse);
    test:assertEquals(files.files[0]?.size, 1);
    test:assertEquals(files.files[1]?.size, ());

    ChangeList changes = check normalizeFileListJson({
        changes: [{fileId: "a", file: {id: "a", size: "2"}}, {fileId: "b", removed: true}]
    }).cloneWithType(ChangeList);
    test:assertEquals(changes.changes[0].file?.size, 2);
}

@test:Config {}
function testFilesResponseWithoutKind() returns error? {
    FilesResponse files = check normalizeFileListJson({files: [{id: "a"}]}).cloneWithType(FilesResponse);
    test:assertEquals(files.kind, "drive#fileList");
}

@test:Config {}
function testEscapeQueryValue() {
    test:assertEquals(escapeQueryValue("plain"), "plain");
    test:assertEquals(escapeQueryValue("O'Brien"), "O\\'Brien");
    test:assertEquals(escapeQueryValue("a\\b"), "a\\\\b");
    test:assertEquals(escapeQueryValue("x' or name contains 'y"), "x\\' or name contains \\'y");
}

@test:Config {}
function testCorporaQueryParameter() {
    string url = prepareUrlwithFileListOptional({corpora: "drive", driveId: "d1"});
    test:assertTrue(url.includes("corpora=drive"), "corpora must be sent as `corpora`");
    test:assertFalse(url.includes("uploadType"), "corpora must not be sent as `uploadType`");
}

@test:Config {}
function testDriveErrorDetail() {
    json body = {"error": {code: 404, message: "File not found", errors: [{reason: "notFound"}]}};
    error err = getDriveError(body, 404);
    test:assertEquals(err.message(), body.toString());
    test:assertEquals(err.detail()["statusCode"], 404);
    test:assertEquals(err.detail()["reason"], "notFound");

    // Status code falls back to the one in the response body
    test:assertEquals(getDriveError(body).detail()["statusCode"], 404);
}

@test:Config {}
function testInitDoesNotMutateConfig() returns error? {
    ConnectionConfig config = {auth: {token: "dummy"}};
    Client _ = check new (config);
    test:assertEquals(config.http1Settings, ());
}

@test:Config {}
function testChangeListKeepsPageTokens() returns error? {
    ChangeList last = check normalizeFileListJson({
        changes: [{fileId: "a", file: {id: "a", size: "5"}}],
        newStartPageToken: "163447"
    }).cloneWithType(ChangeList);
    test:assertEquals(last.newStartPageToken, "163447");
    test:assertEquals(last?.nextPageToken, ());
    test:assertEquals(last.changes[0].file?.size, 5);
}
