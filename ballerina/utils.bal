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
# + statusCode - HTTP status code of the response, if known
# + return - error if not exist.
isolated function getDriveError(json|error errorResponse, int? statusCode = ()) returns error {
    if (errorResponse is json) {
        int? code = statusCode;
        string? reason = ();
        if errorResponse is map<json> {
            json body = errorResponse["error"];
            if body is map<json> {
                json bodyCode = body["code"];
                if code is () && bodyCode is int {
                    code = bodyCode;
                }
                json errors = body["errors"];
                if errors is json[] && errors.length() > 0 {
                    json first = errors[0];
                    if first is map<json> {
                        json bodyReason = first["reason"];
                        if bodyReason is string {
                            reason = bodyReason;
                        }
                    }
                }
            }
        }
        // The message is kept as the raw response body for backward compatibility
        return error(errorResponse.toString(), statusCode = code, reason = reason);
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
        return getDriveError(response, statusCode);
    }
}

# Escapes a value to be used inside a single-quoted string of a Drive search query.
#
# + value - The raw value
# + return - The value with backslashes and single quotes escaped
isolated function escapeQueryValue(string value) returns string {
    return re `'`.replaceAll(re `\\`.replaceAll(value, "\\\\"), "\\'");
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
        if (optional?.alt is string) {
            optionalMap[ALT] = optional?.alt.toString();
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

# Prepare URL for export.
#
# + fileId - File id
# + mimeType - MIME type of the file to be exported
# + return - The prepared URL with encoded query
isolated function prepareExportUrl(string fileId, string mimeType) returns string {
    string path = prepareUrl([DRIVE_PATH, FILES, fileId, "export"]);
    string encodedMimeType = checkpanic url:encode(mimeType, ENCODING_CHARSET);
    path = path + QUESTION_MARK + "mimeType=" + encodedMimeType;
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
        optionalMap[SUPPORTS_ALL_DRIVES] = optional?.supportsAllDrives.toString();
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
           optionalMap[CORPORA] = optional?.corpora.toString();
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
# + httpClient - Http client  
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
# + httpClient - Http client  
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
    File|error file = normalizeFileJson(response).cloneWithType(File);
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
    File|error file = normalizeFileJson(response).cloneWithType(File);
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
# + fileResource - 'FileMetadata' can be added as a payload to change metadata
# + optional - 'UpdateFileMetadataOptional' used to add query parameters to the request
# + return - If successful, returns `File`. Else returns `error`
isolated function updateFileById(http:Client httpClient, string fileId, FileMetadata? fileResource = (), 
                            UpdateFileMetadataOptional? optional = ()) returns @tainted File|error {
    json payload = check fileResource.cloneWithType(json);
    string path = prepareUrlWithUpdateOptional(fileId, optional);
    json response = check updateRequestWithPayload(httpClient, path, payload);
    File|error file = normalizeFileJson(response).cloneWithType(File);
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
    File|error file = normalizeFileJson(response).cloneWithType(File);
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
    json payload = check fileMetadata.cloneWithType(json);
    json response = check uploadFiles(httpClient, path, filePath);  
    //update metadata
    json responseId = check response.id;
    string fileId = responseId.toString();
    string newFileUrl = prepareUrlWithUpdateOptional(fileId, optional);
    json|error changeResponse = updateRequestWithPayload(httpClient, newFileUrl, payload);
    if changeResponse is error {
        discardUploadedFile(httpClient, fileId);
        return changeResponse;
    }
    File|error file = normalizeFileJson(changeResponse).cloneWithType(File);
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
    FilesResponse|error res = normalizeFilesResponseJson(resp).cloneWithType(FilesResponse);
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
            _ = check getFilesStream(httpClient, files, optional);
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
    json payload = check fileMetadata.cloneWithType(json);
    json response = check uploadFileWithByteArray(httpClient, path, byteArray);
    //update metadata
    json|error responseId = response.id;
    string fileId = EMPTY_STRING;
    if (responseId is json) {
        fileId = responseId.toString();
    }
    string newFileUrl = prepareUrlWithUpdateOptional(fileId, optional);
    json|error changeResponse = updateRequestWithPayload(httpClient, newFileUrl, payload);
    if changeResponse is error {
        discardUploadedFile(httpClient, fileId);
        return changeResponse;
    }
    File|error file = normalizeFileJson(changeResponse).cloneWithType(File);
    if (file is File) {
        return file;
    } else {
        return error(ERR_FILE_RESPONSE, file);
    }
}

# Utility function to retrieve File content as a binary content with its MIME type.
# 
# + httpClient - Drive client
# + path - GET URI path
# + return - `FileContent` if successful, `error` if not.
isolated function generateRecordFileContent(http:Client httpClient, string path) returns @tainted FileContent|error {
    http:Response response = <http:Response> check httpClient->get(<@untainted>path);
    if (response.statusCode == http:STATUS_OK) {
        return {
            content: check response.getBinaryPayload(),
            mimeType: response.getContentType()
        }; 
    } else {
        fail error(check response.getTextPayload());
    }
}

# Build `/changes` list URL with optional query parameters.
#
# + pageToken - The page token to start from
# + optional - Optional query parameters
# + return - The prepared URL with encoded query
isolated function prepareUrlWithChangesOptional(string pageToken,
        ListChangesOptional? optional = ()) returns string {

    string path = prepareUrl([DRIVE_PATH, CHANGES]);

    // Mandatory pageToken first
    map<string> queryParams = {};
    queryParams[PAGE_TOKEN] = pageToken;

    if optional is ListChangesOptional {
        if optional.pageSize is int {
            queryParams[PAGE_SIZE] = optional.pageSize.toString();
        }
        if optional.driveId is string {
            queryParams[DRIVE_ID] = <string>optional.driveId;
        }
        if optional.fields is string {
            queryParams[FIELDS] = <string>optional.fields;
        }
        if optional.supportsAllDrives is boolean {
            queryParams[SUPPORTS_ALL_DRIVES] = optional.supportsAllDrives.toString();
        }
        if optional.includeItemsFromAllDrives is boolean {
            queryParams[INCLUDE_ITEMS_FROM_ALL_DRIVES] =
                optional.includeItemsFromAllDrives.toString();
        }
        if optional.includeRemoved is boolean {
            queryParams[INCLUDE_REMOVED] = optional.includeRemoved.toString();
        }
        if optional.includeCorpusRemovals is boolean {
            queryParams[INCLUDE_CORPUS_REMOVALS] = optional.includeCorpusRemovals.toString();
        }
        if optional.restrictToMyDrive is boolean {
            queryParams[RESTRICT_TO_MY_DRIVE] = optional.restrictToMyDrive.toString();
        }
    }

    return prepareQueryUrl([path], queryParams.keys(), queryParams.toArray());
}


// Drive returns int64 fields as JSON strings (e.g. "size": "12345"), which `cloneWithType` does not convert to `int`.
final readonly & string[] INT64_FILE_FIELDS = ["size", "quotaBytesUsed", "version", "thumbnailVersion"];

# Converts the string-encoded int64 fields of a Drive file JSON object to numbers, in place of the lax conversion.
# `appProperties` and `properties` hold user-defined values and are left untouched.
#
# + fileJson - JSON representation of a file, as returned by the Drive API
# + return - The JSON with numeric values in place of the string-encoded ones
isolated function normalizeFileJson(json fileJson) returns json {
    if fileJson !is map<json> {
        return fileJson;
    }
    map<json> file = fileJson;
    foreach string fieldName in INT64_FILE_FIELDS {
        json value = file[fieldName];
        if value is string {
            int|error parsed = int:fromString(value);
            if parsed is int {
                file[fieldName] = parsed;
            }
        }
    }
    json videoMetadata = file["videoMediaMetadata"];
    if videoMetadata is map<json> {
        json duration = videoMetadata["durationMillis"];
        if duration is string {
            float|error parsed = float:fromString(duration);
            if parsed is float {
                videoMetadata["durationMillis"] = parsed;
            }
        }
    }
    return file;
}

# Normalizes every file in a Drive response that wraps files, i.e. `files[]` of a file list or `changes[].file`
# of a change list.
#
# + responseJson - JSON of a `FilesResponse` or a `ChangeList`
# + return - The JSON with the files normalized
isolated function normalizeFileListJson(json responseJson) returns json {
    if responseJson !is map<json> {
        return responseJson;
    }
    map<json> response = responseJson;
    json files = response["files"];
    if files is json[] {
        foreach int i in 0 ..< files.length() {
            files[i] = normalizeFileJson(files[i]);
        }
    }
    json changes = response["changes"];
    if changes is json[] {
        foreach json change in changes {
            if change is map<json> && change.hasKey("file") {
                change["file"] = normalizeFileJson(change["file"]);
            }
        }
    }
    return response;
}

# Deletes a file whose content was uploaded but whose metadata update failed, so that no unnamed file is left behind.
# Failures are ignored, since the caller reports the original error.
#
# + httpClient - The HTTP Client
# + fileId - ID of the uploaded file
isolated function discardUploadedFile(http:Client httpClient, string fileId) {
    if fileId == EMPTY_STRING {
        return;
    }
    boolean|error result = deleteRequest(httpClient, prepareUrlWithDeleteOptional(fileId, {supportsAllDrives: true}));
    if result is error {
        log:printDebug("Unable to remove the partially uploaded file " + fileId, 'error = result);
    }
}

# Normalizes a file list response (`FilesResponse`). `files` and `kind` are absent when the `fields` mask leaves them
# out, so they default to an empty list and `drive#fileList`.
#
# + responseJson - JSON of a file list response
# + return - The JSON with the files normalized and the defaults applied
isolated function normalizeFilesResponseJson(json responseJson) returns json {
    json normalized = normalizeFileListJson(responseJson);
    if normalized is map<json> {
        if !normalized.hasKey("files") {
            normalized["files"] = [];
        }
        if !normalized.hasKey("kind") {
            normalized["kind"] = "drive#fileList";
        }
    }
    return normalized;
}

# Adds `nextPageToken` to a file list `fields` mask when missing. Without it Drive omits the token, and the connector
# would stop after the first page.
#
# + fields - The caller's `fields` mask, e.g. `files(id,name,size)`
# + return - The mask including `nextPageToken`
isolated function includeNextPageToken(string fields) returns string {
    string trimmed = fields.trim();
    if trimmed == "*" || trimmed.includes("nextPageToken") {
        return fields;
    }
    return "nextPageToken," + fields;
}
