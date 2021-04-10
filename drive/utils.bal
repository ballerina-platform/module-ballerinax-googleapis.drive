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

import ballerina/url;
import ballerina/http;
import ballerina/io;
import ballerina/log;

# Send GET request.
# 
# + httpClient - Drive client
# + path - GET URI path
# + return - JSON or error if not suceeded
isolated function sendRequest(http:Client httpClient, string path) returns @tainted json|error {
    http:Response httpResponse = <http:Response> check httpClient->get(<@untainted>path);
    int statusCode = httpResponse.statusCode;
    json|http:ClientError jsonResponse = httpResponse.getJsonPayload();
    if (jsonResponse is json) {
        error? validateStatusCodeRes = validateStatusCode(jsonResponse, statusCode);
        if (validateStatusCodeRes is error) {
            return validateStatusCodeRes;
        }
        return jsonResponse;
    } else {
        return getDriveError(jsonResponse);
    }
}

# Send DELETE request.
# 
# + httpClient - Drive client
# + path - DELETE URI path
# + return - boolean or error if not suceeded, True if Deleted successfully.
isolated function deleteRequest(http:Client httpClient, string path) returns @tainted boolean|error {
    http:Response httpResponse = <http:Response> check httpClient->delete(<@untainted>path);
    if(httpResponse.statusCode == http:STATUS_NO_CONTENT){
        return true;
    }
    json | http:ClientError jsonResponse = httpResponse.getJsonPayload();
    return getDriveError(jsonResponse);
}

# Stop channel watching.
# 
# + httpClient - Drive client
# + return - boolean or error if not suceeded, True if Deleted successfully.
isolated function stopChannelRequest(http:Client httpClient, string path, json jsonPayload) returns @tainted boolean|error {
    http:Request httpRequest = new;
    if (jsonPayload != ()) {
        httpRequest.setJsonPayload(<@untainted>jsonPayload);
    }
    http:Response httpResponse = <http:Response> check httpClient->post(<@untainted>path, httpRequest);
    int statusCode = httpResponse.statusCode;
    if(httpResponse.statusCode == http:STATUS_NO_CONTENT){
        return true;
    }
    json | http:ClientError jsonResponse = httpResponse.getJsonPayload();
    return getDriveError(jsonResponse);
}

# Send POST request with  a Payload.
# 
# + httpClient - Drive client
# + path - POST URI path
# + jsonPayload - Payload of the request.
# + return - json or error if not suceeded.
isolated function sendRequestWithPayload(http:Client httpClient, string path, json jsonPayload) returns @tainted json|error {
    http:Request httpRequest = new;
    if (jsonPayload != ()) {
        httpRequest.setJsonPayload(<@untainted>jsonPayload);
    }
    http:Response httpResponse = <http:Response> check httpClient->post(<@untainted>path, httpRequest);
    int statusCode = httpResponse.statusCode;
    json | http:ClientError jsonResponse = httpResponse.getJsonPayload();
    if (jsonResponse is json) {
        error? validateStatusCodeRes = validateStatusCode(jsonResponse, statusCode);
        if (validateStatusCodeRes is error) {
            return validateStatusCodeRes;
        }
        return jsonResponse;
    } else {
        return getDriveError(jsonResponse);
    }
}

# Send PATCH request with  a Payload.
# 
# + httpClient - Drive client
# + path - PATCH URI path
# + jsonPayload - Payload of the request
# + return - json or error if not suceeded.
isolated function updateRequestWithPayload(http:Client httpClient, string path, json jsonPayload) returns @tainted json|error {
    http:Request httpRequest = new;
    if (jsonPayload != ()) {
        httpRequest.setJsonPayload(<@untainted>jsonPayload);
    }
    http:Response httpResponse = <http:Response> check httpClient->patch(<@untainted>path, httpRequest);
    int statusCode = httpResponse.statusCode;
    json|http:ClientError jsonResponse = httpResponse.getJsonPayload();
    if (jsonResponse is json) {
        error? validateStatusCodeRes = validateStatusCode(jsonResponse, statusCode);
        if (validateStatusCodeRes is error) {
            return validateStatusCodeRes;
        }
        return jsonResponse;
    } else {
        return getDriveError(jsonResponse);
    }
}

# Send POST request with  a Payload.
# 
# + httpClient - Drive client
# + path - POST URI path
# + jsonPayload - Payload of the request
# + return - json or error if not suceeded.
isolated function uploadRequestWithPayload(http:Client httpClient, string path, json jsonPayload) returns @tainted json|error {
    http:Request httpRequest = new;
    if (jsonPayload != ()) {
        httpRequest.setJsonPayload(<@untainted>jsonPayload);
    }
    http:Response httpResponse = <http:Response> check httpClient->post(<@untainted>path, httpRequest);
    int statusCode = httpResponse.statusCode;
    json|http:ClientError jsonResponse = httpResponse.getJsonPayload();
    if (jsonResponse is json) {
        error? validateStatusCodeRes = validateStatusCode(jsonResponse, statusCode);
        if (validateStatusCodeRes is error) {
            return validateStatusCodeRes;
        }
        return jsonResponse;
    } else {
        return getDriveError(jsonResponse);
    }
}

# Formation of error message
# 
# + errorResponse - Can be json or error type
# + return - error if not exist.
isolated function getDriveError(json|error errorResponse) returns error {
  if (errorResponse is json) {
        return error(errorResponse.toString());
  } else {
        return errorResponse;
  }
}

# Prepare Validate Status Code.
# 
# + response - JSON response fromthe request
# + statusCode - The Status code
# + return - Error Message
isolated function validateStatusCode(json response, int statusCode) returns error? {
    if (statusCode != http:STATUS_OK) {
        return getDriveError(response);
    }
}

# Prepare URL.
# 
# + paths - An array of paths prefixes
# + return - The prepared URL
isolated function prepareUrl(string[] paths) returns string {
    string url = EMPTY_STRING;
    if (paths.length() > 0) {
        foreach var path in paths {
            if (!path.startsWith(FORWARD_SLASH)) {
                url = url + FORWARD_SLASH;
            }
            url = url + path;
        }
    }
    return <@untainted>url;
}

# Prepare URL with encoded query.
# 
# + paths - An array of paths prefixes
# + queryParamNames - An array of query param names
# + queryParamValues - An array of query param values
# + return - The prepared URL with encoded query
isolated function prepareQueryUrl(string[] paths, string[] queryParamNames, string[] queryParamValues) returns string {
    string url = prepareUrl(paths);
    url = url + QUESTION_MARK;
    boolean first = true;
    int i = 0;
    foreach var name in queryParamNames {
        string value = queryParamValues[i];
        string|url:Error encoded = url:encode(value, ENCODING_CHARSET);
        if (encoded is string) {
            if (first) {
                url = url + name + EQUAL + encoded;
                first = false;
            } else {
                url = url + AMPERSAND + name + EQUAL + encoded;
            }
        } else {
            log:printError(UNABLE_TO_ENCODE + value, 'error = encoded);
            break;
        }
        i = i + 1;
    }
    return url;
}

# Prepare URL with optional parameters.
# 
# + fileId - File id
# + optional - Record that contains optional parameters
# + return - The prepared URL with encoded query
isolated function prepareUrlWithFileOptional(string fileId , GetFileOptional? optional = ()) returns string {
    string[] value = [];
    map<string> optionalMap = {};
    string path = prepareUrl([DRIVE_PATH, FILES, fileId]);
    if (optional is GetFileOptional) {
        if (optional?.acknowledgeAbuse is boolean) {
            optionalMap[ACKKNOWLEDGE_ABUSE] = optional?.acknowledgeAbuse.toString();
        }
        if (optional?.fields is string) {
            optionalMap[FIELDS] = optional?.fields.toString();
        }
        if (optional?.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional?.includePermissionsForView.toString();
        }
        if (optional?.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional?.supportsAllDrives.toString();
        }
        foreach var val in optionalMap {
            value.push(val);
        }
        path = prepareQueryUrl([path], optionalMap.keys(), value);
    }
    return path;
}

# Prepare URL with optional parameters on Delete Request
# 
# + fileId - File id
# + optional - Delete Record that contains optional parameters
# + return - The prepared URL with encoded query
isolated function prepareUrlWithDeleteOptional(string fileId , DeleteFileOptional? optional = ()) returns string {
    string[] value = [];
    map<string> optionalMap = {};
    string path = prepareUrl([DRIVE_PATH, FILES, fileId]);
    if (optional is DeleteFileOptional) {
        if (optional?.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional?.supportsAllDrives.toString();
        }
        foreach var val in optionalMap {
            value.push(val);
        }
        path = prepareQueryUrl([path], optionalMap.keys(), value);
    }
    return path;
}

# Prepare URL with optional parameters on Copy Request
# 
# + fileId - File id
# + optional - Copy Record that contains optional parameters
# + return - The prepared URL with encoded query
isolated function prepareUrlWithCopyOptional(string fileId , CopyFileOptional? optional = ()) returns string {
    string[] value = [];
    map<string> optionalMap = {};
    string path = prepareUrl([DRIVE_PATH, FILES, fileId, COPY]);
    if (optional is CopyFileOptional) {
        if (optional?.fields is string) {
            optionalMap[FIELDS] = optional?.fields.toString();
        }
        if (optional?.ignoreDefaultVisibility is boolean) {
            optionalMap[IGNORE_DEFAULT_VISIBILITY] = optional?.ignoreDefaultVisibility.toString();
        }
        if (optional?.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional?.includePermissionsForView.toString();
        }
        if (optional?.keepRevisionForever is boolean) {
            optionalMap[KEEP_REVISION_FOREVER] = optional?.keepRevisionForever.toString();
        }
        if (optional?.ocrLanguage is string) {
            optionalMap[OCR_LANGUAGE] = optional?.ocrLanguage.toString();
        }
        if (optional?.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional?.supportsAllDrives.toString();
        }
        foreach var val in optionalMap {
            value.push(val);
        }
        path = prepareQueryUrl([path], optionalMap.keys(), value);
    }
    return path;
}

# Prepare URL with optional parameters on Update Request
# 
# + fileId - File id
# + optional - Update Record that contains optional parameters
# + return - The prepared URL with encoded query
isolated function prepareUrlWithUpdateOptional(string fileId , UpdateFileMetadataOptional? optional = ()) 
                                                returns string {
    string[] value = [];
    map<string> optionalMap = {};
    string path = prepareUrl([DRIVE_PATH, FILES, fileId]);
    if (optional is UpdateFileMetadataOptional) {
        // Optional Query Params
        if (optional?.addParents is string) {
            optionalMap[ADD_PARENTS] = optional?.addParents.toString();
        }
        if (optional?.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional?.includePermissionsForView.toString();
        }
        if (optional?.keepRevisionForever is boolean) {
            optionalMap[KEEP_REVISION_FOREVER] = optional?.keepRevisionForever.toString();
        }
        if (optional?.ocrLanguage is string) {
            optionalMap[OCR_LANGUAGE] = optional?.ocrLanguage.toString();
        }
        if (optional?.removeParents is string) {
            optionalMap[REMOVE_PARENTS] = optional?.removeParents.toString();
        }
        if (optional?.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional?.supportsAllDrives.toString();
        }
        if (optional?.useContentAsIndexableText is boolean) {
            optionalMap[USE_CONTENT_AS_INDEXABLE_TEXT] = optional?.useContentAsIndexableText.toString();
        }
    }
    foreach var val in optionalMap {
        value.push(val);
    }
    path = prepareQueryUrl([path], optionalMap.keys(), value);
    return path;
}

# Prepare URL with optional parameters.
# 
# + optional - Record that contains optional parameters
# + return - The prepared URL with encoded query
isolated function prepareUrlwithMetadataFileOptional(CreateFileOptional? optional = ()) returns string {    
    string[] value = [];
    map<string> optionalMap = {};
    string path = prepareUrl([DRIVE_PATH, FILES]);
    if (optional is CreateFileOptional) {
        //Optional Params
        if (optional?.ignoreDefaultVisibility is boolean) {
            optionalMap[IGNORE_DEFAULT_VISIBILITY] = optional?.ignoreDefaultVisibility.toString();
        }
        if (optional?.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional?.includePermissionsForView.toString();
        }
        if (optional?.keepRevisionForever is boolean) {
            optionalMap[KEEP_REVISION_FOREVER] = optional?.keepRevisionForever.toString();
        }
        if (optional?.ocrLanguage is string) {
            optionalMap[OCR_LANGUAGE] = optional?.ocrLanguage.toString();
        }
        if (optional?.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional?.supportsAllDrives.toString();
        }
        if (optional?.useContentAsIndexableText is boolean) {
            optionalMap[USE_CONTENT_AS_INDEXABLE_TEXT] = optional?.useContentAsIndexableText.toString();
        }
        foreach var val in optionalMap {
            value.push(val);
        }
        path = prepareQueryUrl([path], optionalMap.keys(), value);
    }
    return path;
}

# Prepare URL with optional parameters.
# 
# + optional - Record that contains optional parameters
# + return - The prepared URL with encoded query
isolated function prepareUrlwithFileListOptional(ListFilesOptional? optional = ()) returns string {
    string[] value = [];
    map<string> optionalMap = {};
    string path = prepareUrl([DRIVE_PATH, FILES]);
    if (optional is ListFilesOptional) {
        //Optional Params
        if (optional?.corpora is string){
           optionalMap[UPLOAD_TYPE] = optional?.corpora.toString();
        }
        if (optional?.driveId is string) {
            optionalMap[DRIVE_ID] = optional?.driveId.toString();
        }
        if (optional?.fields is string) {
            optionalMap[FIELDS] = optional?.fields.toString();
        }
        if (optional?.includeItemsFromAllDrives is boolean) {
            optionalMap[INCLUDE_ITEMS_FROM_ALL_DRIVES] = optional?.includeItemsFromAllDrives.toString();
        }
        if (optional?.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional?.includePermissionsForView.toString();
        }
        if (optional?.orderBy is string) {
            optionalMap[ORDER_BY] = optional?.orderBy.toString();
        }
        if (optional?.pageSize is int) {
            optionalMap[PAGE_SIZE] = optional?.pageSize.toString();
        }
        if (optional?.pageToken is string) {
            optionalMap[PAGE_TOKEN] = optional?.pageToken.toString();
        }
        if (optional?.q is string) {
            optionalMap[Q] = optional?.q.toString();
        }
        if (optional?.spaces is string) {
            optionalMap[SPACES] = optional?.spaces.toString();
        }
        if (optional?.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional?.supportsAllDrives.toString();
        }
        foreach var val in optionalMap {
            value.push(val);
        }
        path = prepareQueryUrl([path], optionalMap.keys(), value);
    }
    return path;
}

# Upload files
# 
# + path - Formatted URI 
# + filePath - File path subjected to upload
# + return - Json response or Error
isolated function uploadFiles(http:Client httpClient, string path, string filePath) returns @tainted json|error {
    http:Request httpRequest = new;
    byte[] fileContentByteArray = check io:fileReadBytes(filePath);
    httpRequest.setHeader(CONTENT_LENGTH ,fileContentByteArray.length().toString());
    httpRequest.setBinaryPayload(<@untainted> fileContentByteArray);
    http:Response httpResponse = <http:Response> check httpClient->post(<@untainted>path, httpRequest);     
    int statusCode = httpResponse.statusCode;
    json|http:ClientError jsonResponse = httpResponse.getJsonPayload();
    if (jsonResponse is json) {
        error? validateStatusCodeRes = validateStatusCode(jsonResponse, statusCode);
        if (validateStatusCodeRes is error) {
            return validateStatusCodeRes;
        }
        return jsonResponse;
    } else {
        return getDriveError(jsonResponse);
    }
}

# Upload files using a byte Array
# 
# + path - Formatted URI 
# + byteArray - Byte Array subjected to upload
# + return - Json response or Error
isolated function uploadFileWithByteArray(http:Client httpClient, string path, byte[] byteArray) returns @tainted json|error {
    http:Request httpRequest = new;
    httpRequest.setHeader(CONTENT_LENGTH ,byteArray.length().toString());
    httpRequest.setBinaryPayload(<@untainted> byteArray);
    http:Response httpResponse = <http:Response> check httpClient->post(<@untainted>path, httpRequest);
        int statusCode = httpResponse.statusCode;
        json|http:ClientError jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            error? validateStatusCodeRes = validateStatusCode(jsonResponse, statusCode);
            if (validateStatusCodeRes is error) {
                return validateStatusCodeRes;
            }
            return jsonResponse;
        } else {
            return getDriveError(jsonResponse);
        }
}

# Gets information about the user, the user's Drive, and system capabilities.
# 
# + httpClient - The HTTP Client 
# + fields - The paths of the fields you want included in the response
# + return - If successful, returns `About`. Else returns `error`
isolated function getDriveInfo(http:Client httpClient, string? fields) returns @tainted About|error {
    string path = DRIVE_PATH + ABOUT + QUESTION_MARK + FIELDS + EQUAL + _ALL;
    if (fields is string) {
        path = DRIVE_PATH + ABOUT + QUESTION_MARK + FIELDS + EQUAL + fields;
    }
    json response = check sendRequest(httpClient, path);
    About|error info = response.cloneWithType(About);
    if (info is About) {
        return info;
    } else {
        return error(ERR_DRIVE_INFO_RESPONSE, info);
    }
}

# Retrieve file using the fileID.
# 
# + httpClient - The HTTP Client 
# + fileId - ID of the file to retreive
# + optional - 'GetFileOptional' used to add query parameters to the request
# + return - If successful, returns `File`. Else returns `error`
isolated function getFileById(http:Client httpClient, string fileId,  GetFileOptional? optional = ()) 
                        returns @tainted File|error {
    string path = prepareUrlWithFileOptional(fileId, optional);
    json response = check sendRequest(httpClient, path);
    File|error file = response.cloneWithType(File);
    if (file is File) {
        return file;
    } else {
        return error(ERR_FILE_RESPONSE, file);
    }
}

# Delete file using the fileID.
# 
# + httpClient - The HTTP Client
# + fileId - ID of the file to delete
# + optional - 'DeleteFileOptional' used to add query parameters to the request
# + return - If successful, returns `boolean` as true. Else returns `error`
isolated function deleteFileById(http:Client httpClient, string fileId, DeleteFileOptional? optional = ()) 
                            returns @tainted boolean|error {
    string path = prepareUrlWithDeleteOptional(fileId, optional);
    boolean|error response = deleteRequest(httpClient, path);
    return response;
}


# Copy file using the fileID.
# 
# + httpClient - The HTTP Client
# + fileId - ID of the file to copy
# + optional - 'CopyFileOptional' used to add query parameters to the request
# + fileResource - 'File' can added as a payload to change metadata
# + return - If successful, returns `File`. Else returns `error`
isolated function copyFile(http:Client httpClient, string fileId, CopyFileOptional? optional = (), 
                 File? fileResource = ()) returns @tainted File|error {
    json payload = check fileResource.cloneWithType(json);
    string path = prepareUrlWithCopyOptional(fileId, optional);
    json response = check sendRequestWithPayload(httpClient, path, payload);
    File|error file = response.cloneWithType(File);
    if (file is File) {
        return file;
    } else {
        return error(ERR_FILE_RESPONSE, file);
    }
}

# Update file metadata using the fileID.
# 
# + httpClient - The HTTP Client
# + fileId - ID of the file to be updated
# + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
# + fileResource - 'File' can added as a payload to change metadata
# + return - If successful, returns `File`. Else returns `error`
isolated function updateFileById(http:Client httpClient, string fileId, File? fileResource = (), 
                            UpdateFileMetadataOptional? optional = ()) returns @tainted File|error {
    json payload = check fileResource.cloneWithType(json);
    string path = prepareUrlWithUpdateOptional(fileId, optional);
    json response = check updateRequestWithPayload(httpClient, path, payload);
    File|error file = response.cloneWithType(File);
    if (file is File) {
        return file;
    } else {
        return error(ERR_FILE_RESPONSE, file);
    }
}

# Create new file (with only metadata).
# 
# + httpClient - The HTTP Client
# + optional - 'CreateFileOptional' used to add query parameters to the request
# + fileData - 'File' Metadata is send to in the payload 
# + return - If successful, returns `File`. Else returns `error`
isolated function createMetaDataFile(http:Client httpClient, File? fileData = (), CreateFileOptional? optional = ()) 
                                returns @tainted File|error {
    json payload = check fileData.cloneWithType(json);
    string path = prepareUrlwithMetadataFileOptional(optional);
    json response = check uploadRequestWithPayload(httpClient, path, payload);
    File|error file = response.cloneWithType(File);
    if (file is File) {
        return file;
    } else {
        return error(ERR_FILE_RESPONSE, file);
    }
}

# Upload new file.
# 
# + httpClient - The HTTP Client
# + filePath - Path to the file object to be uploaded
# + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
# + fileMetadata - 'File' Metadata is send to in the payload 
# + return - If successful, returns `File`. Else returns `error`
isolated function uploadFile(http:Client httpClient, string filePath, File? fileMetadata = (), 
                        UpdateFileMetadataOptional? optional = ()) returns @tainted File|error {    
    string path = prepareUrl([UPLOAD, DRIVE_PATH, FILES]);  
    json response = check uploadFiles(httpClient, path, filePath);  
    //update metadata
    json responseId = check response.id;
    string fileId = responseId.toString();
    string newFileUrl = prepareUrlWithUpdateOptional(fileId, optional);
    json payload = check fileMetadata.cloneWithType(json);
    json changeResponse = check updateRequestWithPayload(httpClient, newFileUrl, payload);
    File|error file = changeResponse.cloneWithType(File);
    if (file is File) {
        return file;
    } else {
        return error(ERR_FILE_RESPONSE, file);
    }
}

# Retrieve files.
# 
# + httpClient - The HTTP Client
# + optional - 'ListFilesOptional' used to add query parameters to the request
# + return - If successful, returns stream of files `stream<File>`. Else returns `error`
isolated function getFiles(http:Client httpClient, ListFilesOptional? optional) returns @tainted stream<File>|error {
    File[] files = [];
    return getFilesStream(httpClient, files, optional);
}

# Get files stream.
# 
# + httpClient - The HTTP Client
# + files - File array
# + optional - 'ListFilesOptional' used to add query parameters to the request
# + return - File stream on success, else an error
isolated function getFilesStream(http:Client httpClient, @tainted File[] files, ListFilesOptional? optional = ()) 
                            returns @tainted stream<File>|error {
    string path = prepareUrlwithFileListOptional(optional);
    json resp = check sendRequest(httpClient, path);
    FilesResponse|error res = resp.cloneWithType(FilesResponse);
    if (res is FilesResponse) {
        int i = files.length();
        foreach File item in res.files {
            files[i] = item;
            i = i + 1;
        }        
        stream<File> filesStream = (<@untainted>files).toStream();
        string? nextPageToken = res?.nextPageToken;
        if (nextPageToken is string && optional is ListFilesOptional) {
            optional.pageToken = nextPageToken;
            var streams = check getFilesStream(httpClient, files, optional);
        }
        return filesStream;
    } else {
        return error(ERR_FILE_RESPONSE, res);
    }
}

# Upload new file using a Byte array.
# 
# + httpClient - The HTTP Client
# + byteArray - Byte array that represents the file object
# + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
# + fileMetadata - 'File' Metadata is send to in the payload 
# + return - If successful, returns `File`. Else returns `error`
isolated function uploadFileUsingByteArray(http:Client httpClient, byte[] byteArray, File? fileMetadata = (), 
                                    UpdateFileMetadataOptional? optional = ()) returns @tainted File|error {    
    string path = prepareUrl([UPLOAD, DRIVE_PATH, FILES]);
    json response = check uploadFileWithByteArray(httpClient, path, byteArray);
    //update metadata
    json|error responseId = response.id;
    string fileId = EMPTY_STRING;
    if (responseId is json) {
        fileId = responseId.toString();
    }
    string newFileUrl = prepareUrlWithUpdateOptional(fileId, optional);
    json payload = check fileMetadata.cloneWithType(json);
    json changeResponse = check updateRequestWithPayload(httpClient, newFileUrl, payload);
    File|error file = changeResponse.cloneWithType(File);
    if (file is File) {
        return file;
    } else {
        return error(ERR_FILE_RESPONSE, file);
    }
}

# Subscribes to in a specific file.
# 
# + httpClient - The HTTP Client
# + fileId - Id of the file that needs to be subscribed for watching
# + fileWatchRequest - 'WatchResponse' record as request body of the request.
# + optional - 'WatchFileOptional' object with optional params.
# + return - If successful, returns `WatchResponse`. Else returns `error` 
isolated function watchFilesById(http:Client httpClient, string fileId, WatchResponse? fileWatchRequest = (), 
                        WatchFileOptional? optional = ()) returns @tainted WatchResponse|error {
    string path = prepareUrlwithWatchFileOptional(optional,fileId);
    json payload = check fileWatchRequest.cloneWithType(json);
    json resp = check sendRequestWithPayload(httpClient, path, payload);
    WatchResponse response = check mapJsonToWatchResponse(<map<json>>resp);
    if (optional?.pageToken is string){
        response.startPageToken = optional?.pageToken.toString();
    }
    return response;
}

# 
# 
# + httpClient - The HTTP Client
# + fileWatchRequest - 'WatchResponse' object
# + return - If successful, returns `WatchResponse`. Else returns `error` 
isolated function watchAllFiles(http:Client httpClient, WatchResponse fileWatchRequest, WatchFileOptional? optional = ()) 
                        returns @tainted WatchResponse|error {
    string path = prepareUrlwithWatchFileOptional(optional);
    json payload = check fileWatchRequest.cloneWithType(json);
    json resp = check sendRequestWithPayload(httpClient, path, payload);
    WatchResponse response = check mapJsonToWatchResponse(<map<json>>resp);
    if (optional?.pageToken is string){
        response.startPageToken = optional?.pageToken.toString();
    }
    return response;
}

# Stop the subscribtions 
# 
# + httpClient - The HTTP Client
# + fileWatchRequest - Id of the file that needs to be subscribed for watching
# + return - If successful, returns `json`. Else returns `error` 
isolated function stopWatch(http:Client httpClient, WatchResponse fileWatchRequest) returns @tainted boolean|error {
    string path = prepareUrl([DRIVE_PATH, CHANNELS, STOP]);
    json payload = check fileWatchRequest.cloneWithType(json);
    boolean resp = check stopChannelRequest(httpClient, path, payload);
    return resp;
}

# Prepare URL with File Watch optional parameters.
# 
# + fileId - File id
# + optional - Record that contains optional parameters
# + return - The prepared URL with encoded query
isolated function prepareUrlwithWatchFileOptional(WatchFileOptional? optional = (),string? fileId = ()) returns string {
    string[] value = [];
    map<string> optionalMap = {};
    string path = EMPTY_STRING;
    if(fileId is string) {
        path = prepareUrl([DRIVE_PATH, FILES, fileId, WATCH]);
    } else {
        path = prepareUrl([DRIVE_PATH, CHANGES, WATCH]);
    }
    if (optional is WatchFileOptional) {
        if (optional?.acknowledgeAbuse is boolean) {
            optionalMap[ACKKNOWLEDGE_ABUSE] = optional?.acknowledgeAbuse.toString();
        }
        if (optional?.fields is string) {
            optionalMap[FIELDS] = optional?.fields.toString();
        }
        if (optional?.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional?.supportsAllDrives.toString();
        }
        if (optional?.pageToken is string) {
            optionalMap[PAGE_TOKEN] = optional?.pageToken.toString();
        }
        foreach var val in optionalMap {
            value.push(val);
        }
        path = prepareQueryUrl([path], optionalMap.keys(), value);
    }
    return path;
}

# List changes by page token 
# 
# + httpClient - The HTTP Client
# + pageToken - The token for continuing a previous list request on the next page. This should be set to the value of 
#               'nextPageToken' from the previous response or to the response from the getStartPageToken method.
# + optional - 'ChangesListOptional' object with optionals
# + return - If successful, returns `json`. Else returns `error` 
isolated function listChangesByPageToken(http:Client httpClient, string pageToken, ChangesListOptional? optional = ()) 
                                    returns @tainted ChangesListResponse|error {
    string path = prepareUrlwithChangesListOptional(pageToken, optional);
    log:printInfo(path);
    json jsonResponse = check sendRequest(httpClient, path);
    ChangesListResponse response = check jsonResponse.cloneWithType(ChangesListResponse);
    return response;
}

# Prepare URL with Watch changes list optional parameters.
# 
# + pageToken - The token for continuing a previous list request on the next page. This should be set to the value of 
#               'nextPageToken' from the previous response or to the response from the getStartPageToken method.
# + optional - Record that contains optional parameters
# + return - The prepared URL with encoded query
isolated function prepareUrlwithChangesListOptional(string pageToken, ChangesListOptional? optional = ()) 
                                                        returns string {
    string[] value = [];
    map<string> optionalMap = {};
    string path = prepareUrl([DRIVE_PATH, CHANGES]);
    optionalMap[PAGE_TOKEN] = pageToken.toString();
    if (optional is ChangesListOptional) {
        if (optional?.driveId is string) {
            optionalMap[DRIVE_ID] = optional?.driveId.toString();
        }
        if (optional?.fields is string) {
            optionalMap[FIELDS] = optional?.fields.toString();
        }
        if (optional?.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional?.supportsAllDrives.toString();
        }
        if (optional?.includeCorpusRemovals is boolean) {
            optionalMap[INCLUDE_CORPUS_REMOVALS] = optional?.includeCorpusRemovals.toString();
        }
        if (optional?.includeItemsFromAllDrives is boolean) {
            optionalMap[INCLUDE_ITEMS_FROM_ALL_DRIVES] = optional?.includeItemsFromAllDrives.toString();
        }
        if (optional?.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional?.includePermissionsForView.toString();
        }
        if (optional?.includeRemoved is boolean) {
            optionalMap[INCLUDE_REMOVED] = optional?.includeRemoved.toString();
        }
        if (optional?.pageSize is int) {
            optionalMap[PAGE_SIZE] = optional?.pageSize.toString();
        }
        if (optional?.restrictToMyDrive is boolean) {
            optionalMap[RESTRICT_TO_MY_DRIVE] = optional?.restrictToMyDrive.toString();
        }
        if (optional?.spaces is string) {
            optionalMap[SPACES] = optional?.spaces.toString();
        }
    }
    foreach var val in optionalMap {
            value.push(val);
    }
    path = prepareQueryUrl([path], optionalMap.keys(), value);
    return path;
}

# Gets the starting pageToken for listing future changes 
# 
# + httpClient - The HTTP Client
# + return - If successful, returns `string`. Else returns `error` 
isolated function getStartPageToken(http:Client httpClient) returns @tainted string|error {
    string path = prepareUrl([DRIVE_PATH, CHANGES, START_PAGE_TOKEN]);
    json jsonResponse = check sendRequest(httpClient, path);
    StartPageTokenResponse response = check jsonResponse.cloneWithType(StartPageTokenResponse);
    return response.startPageToken;
}
