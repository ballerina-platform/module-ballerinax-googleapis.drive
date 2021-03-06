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

import ballerina/encoding;
import ballerina/http;
import ballerina/io;
import ballerina/log;

# Send GET request.
# 
# + httpClient - Drive client
# + path - GET URI path
# + return - JSON or error if not suceeded
function sendRequest(http:Client httpClient, string path) returns @tainted json|error {
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
function deleteRequest(http:Client httpClient, string path) returns @tainted boolean|error {
    http:Response httpResponse = <http:Response> check httpClient->delete(<@untainted>path);
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
function sendRequestWithPayload(http:Client httpClient, string path, json jsonPayload) returns @tainted json|error {
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
function updateRequestWithPayload(http:Client httpClient, string path, json jsonPayload) returns @tainted json|error {
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
function uploadRequestWithPayload(http:Client httpClient, string path, json jsonPayload) returns @tainted json|error {
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
        var encoded = encoding:encodeUriComponent(value, ENCODING_CHARSET);
        if (encoded is string) {
            if (first) {
                url = url + name + EQUAL + encoded;
                first = false;
            } else {
                url = url + AMPERSAND + name + EQUAL + encoded;
            }
        } else {
            log:printError(UNABLE_TO_ENCODE + value, err = encoded);
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
        if (optional.acknowledgeAbuse is boolean) {
            optionalMap[ACKKNOWLEDGE_ABUSE] = optional.acknowledgeAbuse.toString();
        }
        if (optional.fields is string) {
            optionalMap[FIELDS] = optional.fields.toString();
        }
        if (optional.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional.includePermissionsForView.toString();
        }
        if (optional.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional.supportsAllDrives.toString();
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
        if (optional.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional.supportsAllDrives.toString();
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
        if (optional.fields is string) {
            optionalMap[FIELDS] = optional.fields.toString();
        }
        if (optional.ignoreDefaultVisibility is boolean) {
            optionalMap[IGNORE_DEFAULT_VISIBILITY] = optional.ignoreDefaultVisibility.toString();
        }
        if (optional.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional.includePermissionsForView.toString();
        }
        if (optional.keepRevisionForever is boolean) {
            optionalMap[KEEP_REVISION_FOREVER] = optional.keepRevisionForever.toString();
        }
        if (optional.ocrLanguage is string) {
            optionalMap[OCR_LANGUAGE] = optional.ocrLanguage.toString();
        }
        if (optional.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional.supportsAllDrives.toString();
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
        if (optional.addParents is string) {
            optionalMap[ADD_PARENTS] = optional.addParents.toString();
        }
        if (optional.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional.includePermissionsForView.toString();
        }
        if (optional.keepRevisionForever is boolean) {
            optionalMap[KEEP_REVISION_FOREVER] = optional.keepRevisionForever.toString();
        }
        if (optional.ocrLanguage is string) {
            optionalMap[OCR_LANGUAGE] = optional.ocrLanguage.toString();
        }
        if (optional.removeParents is string) {
            optionalMap[REMOVE_PARENTS] = optional.removeParents.toString();
        }
        if (optional.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional.supportsAllDrives.toString();
        }
        if (optional.useContentAsIndexableText is boolean) {
            optionalMap[USE_CONTENT_AS_INDEXABLE_TEXT] = optional.useContentAsIndexableText.toString();
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
        if (optional.ignoreDefaultVisibility is boolean) {
            optionalMap[IGNORE_DEFAULT_VISIBILITY] = optional.ignoreDefaultVisibility.toString();
        }
        if (optional.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional.includePermissionsForView.toString();
        }
        if (optional.keepRevisionForever is boolean) {
            optionalMap[KEEP_REVISION_FOREVER] = optional.keepRevisionForever.toString();
        }
        if (optional.ocrLanguage is string) {
            optionalMap[OCR_LANGUAGE] = optional.ocrLanguage.toString();
        }
        if (optional.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional.supportsAllDrives.toString();
        }
        if (optional.useContentAsIndexableText is boolean) {
            optionalMap[USE_CONTENT_AS_INDEXABLE_TEXT] = optional.useContentAsIndexableText.toString();
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
        if (optional.corpora is string){
           optionalMap[UPLOAD_TYPE] = optional.corpora.toString();
        }
        if (optional.driveId is string) {
            optionalMap[DRIVE_ID] = optional.driveId.toString();
        }
        if (optional.fields is string) {
            optionalMap[FIELDS] = optional.fields.toString();
        }
        if (optional.includeItemsFromAllDrives is boolean) {
            optionalMap[INCLUDE_ITEMS_FROM_ALL_DRIVES] = optional.includeItemsFromAllDrives.toString();
        }
        if (optional.includePermissionsForView is string) {
            optionalMap[INCLUDE_PERMISSIONS_FOR_VIEW] = optional.includePermissionsForView.toString();
        }
        if (optional.orderBy is string) {
            optionalMap[ORDER_BY] = optional.orderBy.toString();
        }
        if (optional.pageSize is int) {
            optionalMap[PAGE_SIZE] = optional.pageSize.toString();
        }
        if (optional.pageToken is string) {
            optionalMap[PAGE_TOKEN] = optional.pageToken.toString();
        }
        if (optional.q is string) {
            optionalMap[Q] = optional.q.toString();
        }
        if (optional.spaces is string) {
            optionalMap[SPACES] = optional.spaces.toString();
        }
        if (optional.supportsAllDrives is boolean) {
            optionalMap[SUPPORTS_ALL_DRIVES] = optional.supportsAllDrives.toString();
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
function uploadFiles(http:Client httpClient, string path, string filePath) returns @tainted json|error {
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
function uploadFileWithByteArray(http:Client httpClient, string path, byte[] byteArray) returns @tainted json|error {
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
function getDriveInfo(http:Client httpClient, string? fields) returns @tainted About|error {
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
function getFileById(http:Client httpClient, string fileId,  GetFileOptional? optional = ()) 
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
function deleteFileById(http:Client httpClient, string fileId, DeleteFileOptional? optional = ()) 
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
function copyFile(http:Client httpClient, string fileId, CopyFileOptional? optional = (), 
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
function updateFileById(http:Client httpClient, string fileId, File? fileResource = (), 
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
function createMetaDataFile(http:Client httpClient, File? fileData = (), CreateFileOptional? optional = ()) 
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
function uploadFile(http:Client httpClient, string filePath, File? fileMetadata = (), 
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
function getFiles(http:Client httpClient, ListFilesOptional? optional = ()) returns @tainted stream<File>|error {
    string path = prepareUrlwithFileListOptional(optional);
    json response = check sendRequest(httpClient, path);
    File[] files = [];
    FilesResponse|error res = response.cloneWithType(FilesResponse);
    if (res is FilesResponse) {
        int i = files.length();
        foreach File item in res.files {
            files[i] = item;
            i = i + 1;
        }        
        stream<File> filesStream = (<@untainted>files).toStream();
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
function uploadFileUsingByteArray(http:Client httpClient, byte[] byteArray, File? fileMetadata = (), 
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
