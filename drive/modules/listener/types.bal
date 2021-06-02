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

import ballerinax/googleapis.drive as drive;

# Record type that handles the available methods in the listener. 
# These values is automatically set from the available methods inside the listener.
#
# + isOnNewFileCreate - Trigger on new file creation.  
# + isOnNewFolderCreate - Trigger on new folder creation.  
# + isOnFileUpdate - Trigger on file update.
# + isOnFolderUpdate - Trigger on folder update.   
# + isOnFileTrash - Trigger on file trash operation (Temporary delete).
# + isOnFolderTrash - Trigger on folder trash operation (Temporary delete). 
# + isOnDelete - Trigger on delete operation (Permenantly delete).  
public type MethodNames record {
    boolean isOnNewFileCreate = false;
    boolean isOnNewFolderCreate = false;
    boolean isOnFileUpdate = false;
    boolean isOnFolderUpdate = false;
    boolean isOnFileTrash = false;
    boolean isOnFolderTrash = false;
    boolean isOnDelete = false;
};

# Optional parameters for the watch files.
#
# + acknowledgeAbuse - Whether the user is acknowledging the risk of downloading known malware or other abusive files. 
#                      This is only applicable when alt=media. (Default: false)  
# + pageToken - Page Token   
# + fields - The paths of the fields you want included in the response. If not specified, the response includes a 
#            default set of fields specific to this method  
# + supportsAllDrives - Whether the requesting application supports both My Drives and shared drives. (Default: false)  
public type WatchFileOptional record {
    boolean acknowledgeAbuse?;
    string fields?;
    boolean? supportsAllDrives = true;
    string pageToken?;
};

# Response in watch request. 
#
# + resourceId - A UUID or similar unique string that identifies this channel.  
# + address - The address where notifications are delivered for this channel.  
# + payload - A Boolean value to indicate whether payload is wanted.  
# + kind - 	Identifies this as a notification channel used to watch for changes to a resource, which is "api#channel".  
# + expiration - Date and time of notification channel expiration, expressed as a Unix timestamp, in milliseconds.  
# + startPageToken - The starting page token for listing changes.  
# + id - A UUID or similar unique string that identifies this channel.  
# + resourceUri - A version-specific identifier for the watched resource.  
# + params - Additional parameters controlling delivery channel behavior  
# + type - The type of delivery mechanism used for this channel. Valid values are "web_hook" (or "webhook"). 
#          Both values refer to a channel where Http requests are used to deliver messages. 
# + token - An arbitrary string delivered to the target address with each notification delivered over this channel.  
@display {label: "Watch Response"}
public type WatchResponse record {
    string kind?;
    string id?;
    string resourceId?;
    string resourceUri?;
    string token?;
    int expiration?;
    string 'type?;
    string address?;
    boolean payload?;
    string startPageToken?;
    StringKeyValuePairs params?;
};

# Record Type to accpet string values  
public type StringKeyValuePairs record {|
    string...;
|};

# Record which maps the response from list changes request.
#
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#changeList".  
# + nextPageToken - The page token for the next page of changes. This will be absent if the end of the changes list has 
#                   been reached. If the token is rejected for any reason, it should be discarded, and pagination should 
#                   be restarted from the first page of results.  
# + changes - The list of changes. If nextPageToken is populated, then this list may be incomplete and an additional 
#             page of results should be fetched.  
# + newStartPageToken - The starting page token for future changes. This will be present only if the end of the current 
#                       changes list has been reached.  
public type ChangesListResponse record {
    string kind?;
    string nextPageToken?;
    string newStartPageToken?;
    Change[] changes?;
};

type StartPageTokenResponse record {
    string kind?;
    string startPageToken;
};

# A change to a file or shared drive.
#
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#change".  
# + driveId - The ID of the shared drive associated with this change.  
# + removed - Whether the file or shared drive has been removed from this list of changes, for example by deletion or 
#             loss of access.  
# + file - The updated state of the file. Present if the type is file and the file has not been removed from this 
#          list of changes. 
# + changeType - The type of the change. Possible values are file and drive.  
# + time - The time of this change (RFC 3339 date-time). 
# + mimeType - The MIME type of the file.
# + fileId - The ID of the file which has changed.  
public type Change record {
    string kind?;
    string changeType?;
    string mimeType?;
    string time?;
    boolean removed?;
    string fileId?;
    drive:File file?;
    string driveId?;
};
