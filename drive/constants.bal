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

//Base URL
const string BASE_URL = "https://www.googleapis.com";

// URL encoding
const string ENCODING_CHARSET = "utf-8";

//Symbols
const string QUESTION_MARK = "?";
const string PATH_SEPARATOR = "/";
const string EMPTY_STRING = "";
const string WHITE_SPACE = " ";
const string FORWARD_SLASH = "/";
const string DASH_WITH_WHITE_SPACES_SYMBOL = " - ";
const string COLON = ":";
const string EXCLAMATION_MARK = "!";
const string EQUAL = "=";
const string _ALL = "*";
const string TRUE = "true";
const string FALSE = "false";

// Drive
const string DRIVE_URL = "https://www.googleapis.com";
public const string REFRESH_URL = "https://www.googleapis.com/oauth2/v3/token";
const string DRIVE_PATH = "/drive/v3";
const string ABOUT = "/about";
const string UPLOAD = "/upload";
const string UPLOAD_TYPE = "uploadType";
const string TYPE_MEDIA = "media";
const string TYPE_MULTIPART = "multipart";
const string TYPE_RESUMABLE = "resumable";
const string FILES = "/files";
const string CHANGES = "/changes";
const string WATCH = "/watch";
const string COPY = "/copy";
const string CHANNELS = "/channels";
const string STOP = "/stop";
const string Q = "q";
const string AMPERSAND = "&";
const string PAGE_TOKEN = "pageToken";
const string WEB_CONTENT_LINK = "webContentLink";
const string WEB_HOOK = "web_hook";
const string START_PAGE_TOKEN = "startPageToken";

// Error
const string ERR_FILE_RESPONSE = "Error occurred while constructing DriveResponse record.";
const string ERR_WATCH_RESPONSE = "Error occurred while constructing WatchResponse record.";
const string ERR_DRIVE_INFO_RESPONSE = "Error occurred while constructing DriveInfo record.";
const string ERR_JSON_TO_FILE_CONVERT = "Error occurred while constructing File record.";
const string UNABLE_TO_ENCODE = "Unable to encode value: ";
const string ERR_FILE_TO_STRING_CONVERSION = "Unable to convert the file to string: ";
const string ERR_FILE_TO_JSON_CONVERSION = "Unable to convert the file to JSON value: ";
const string ERR_JSON_TO_STRING_CONVERSION = "Unable to convert from JSON to string";
const string HTTP_ERROR_MSG = "Error occurred while getting the HTTP response : ";
const string ERR_EXTRACTING_ERROR_MSG = "Error occured while extracting errors from payload.";
const string JSON_ACCESSING_ERROR_MSG = "Error occurred while accessing the JSON payload of the response.";

// Optional Query Parameters
const string ACKKNOWLEDGE_ABUSE = "acknowledgeAbuse";
const string FIELDS = "fields";
const string INCLUDE_PERMISSIONS_FOR_VIEW = "includePermissionsForView";
const string SUPPORTS_ALL_DRIVES = "supportsAllDrives";
const string IGNORE_DEFAULT_VISIBILITY = "ignoreDefaultVisibility";
const string KEEP_REVISION_FOREVER = "keepRevisionForever";
const string OCR_LANGUAGE = "ocrLanguage";
const string ADD_PARENTS = "addParents";
const string REMOVE_PARENTS = "removeParents";
const string USE_CONTENT_AS_INDEXABLE_TEXT = "useContentAsIndexableText";
const string CORPORA = "corpora";
const string DRIVE_ID = "driveId";
const string ORDER_BY = "orderBy";
const string PAGE_SIZE = "pageSize";
const string SPACES = "spaces";
const string INCLUDE_ITEMS_FROM_ALL_DRIVES = "includeItemsFromAllDrives";
const string INCLUDE_CORPUS_REMOVALS = "includeCorpusRemovals";
const string INCLUDE_REMOVED = "includeRemoved";
const string RESTRICT_TO_MY_DRIVE = "restrictToMyDrive";

// Headers
const string CONTENT_TYPE = "Content-Type";
const string CONTENT_LENGTH = "Content-Length";

// Filter strings
const string FOLDER = "folder";
const string TRASH_FALSE = "trashed = false";
const string AND = "and";
const string SPACE = " ";
const string MIME_TYPE = "mimeType";
const string MIME_PREFIX = "application/vnd.google-apps.";
const string CONTAINS = "contains";
const string NAME = "name";
const string SINGLE_QUOTE = "'";
const string DOCS = "'application/vnd.google-apps.document'";
const string SHEETS = "'application/vnd.google-apps.spreadsheet'";
const string SLIDES = "'application/vnd.google-apps.presentation'";
const string FORMS = "'application/vnd.google-apps.form'";
const string FOLDERS = "'application/vnd.google-apps.folder'";
