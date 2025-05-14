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

import ballerina/http;
import ballerinax/'client.config;

# Client configuration details.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    *config:ConnectionConfig;
    # Configurations related to client authentication
    http:BearerTokenConfig|config:OAuth2RefreshTokenGrantConfig auth;
    # The HTTP version understood by the client
    http:HttpVersion httpVersion = http:HTTP_1_1;
|};

# Client configuration for cookies.
#
# + enabled - User agents provide users with a mechanism for disabling or enabling cookies
# + maxCookiesPerDomain - Maximum number of cookies per domain, which is 50
# + maxTotalCookieCount - Maximum number of total cookies allowed to be stored in cookie store, which is 3000
# + blockThirdPartyCookies - User can block cookies from third party responses and refuse to send cookies for third 
#                            party requests, if needed
public type CookieConfig record {|
    boolean enabled = false;
    int maxCookiesPerDomain = 50;
    int maxTotalCookieCount = 3000;
    boolean blockThirdPartyCookies = true;
|};

# Represents drive information.
#
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#about"
# + user - The authenticated user
# + storageQuota - The user's storage quota limits and usage. All fields are measured in bytes
# + importFormats - A map of source MIME type to possible targets for all supported imports
# + exportFormats - A map of source MIME type to possible targets for all supported exports
# + maxImportSizes - A map of maximum import sizes by MIME type, in bytes
# + maxUploadSize - The maximum upload size in bytes
# + appInstalled - Whether the user has installed the requesting app
# + folderColorPalette - The currently supported folder colors as RGB hex strings
# + driveThemes - A list of themes that are supported for shared drives
# + canCreateDrives - Indicates whether the user can create shared drives
@display {label: "About"}
public type About record {
    string kind?;
    User user?;
    StorageQuota storageQuota?;
    StringArrayValuePairs importFormats?;
    StringArrayValuePairs exportFormats?;
    StringKeyValuePairs maxImportSizes?;
    float maxUploadSize?;
    boolean appInstalled?;
    string[] folderColorPalette?;
    StringKeyValuePairs driveThemes?;
    boolean canCreateDrives?;
};

# Represents File.
@display {label: "File"}
public type File record {
    *FileMetadata;
    *GeneratedFileMetadata;
};

# Represents file metadata.
#
# + name - The name of the file. This is not necessarily unique within a folder.
#          Note that the name is constant for immutable items such as the top level folders of shared drives, 
#          `My Drive` root folder, and the `Application Data` folder
# + mimeType - The MIME (Multipurpose Internet Mail Extensions) type of file. If no value is provided, 
#              Google Drive attempts to automatically detect an appropriate value from uploaded content. 
#              The value cannot be changed unless a new revision is uploaded.
#              If a file is created with a Google Doc MIME type, the uploaded content will be imported if possible. 
#              The supported import formats are published in the `About` resource
# + description - A short description of the file
# + starred - Whether the user has starred the file
# + trashed - Whether the file has been trashed, either explicitly or from a trashed parent folder. Only the owner may 
#             trash a file. The trashed item is excluded from all files.
#             list responses returned for any user who does not own the file.
#             However, all users with access to the file can see the trashed item metadata in an API response.
#             All users with access can copy, download, export, and share the file
# + folderColorRgb - The color for a folder as an RGB hex string
# + appProperties - A collection of arbitrary key-value pairs which are private to the requesting app
# + contentHints - Additional information about the content of the file. These fields are never populated in responses.
# + copyRequiresWriterPermission - Whether the options to copy, print, or download this file, should be disabled for 
#                                  readers and commenters 
# + modifiedTime - The last time the file was modified by anyone (RFC 3339 date-time)  
# + properties - A collection of arbitrary key-value pairs which are visible to all apps
# + originalFilename - The original filename of the uploaded content if available, or else the original value of the 
#                      name field. This is only available for files with binary content in Google Drive
# + viewedByMeTime - The last time the file was viewed by the user (RFC 3339 date-time)
# + writersCanShare - Whether users with only writer permission can modify the file's permissions
@display {label: "File Metadata"}
public type FileMetadata record {
    @display{label: "File Name"} 
    string name?;
    @display{label: "MIME Type"} 
    string mimeType?;
    @display{label: "Description"} 
    string description?;
    @display{label: "Starred"}
    boolean starred?;
    @display{label: "Trashed"}
    boolean trashed?;
    @display{label: "Folder Color in RGB Hex String"} 
    string folderColorRgb?;
    @display{label: "App Properties"} 
    StringKeyValuePairs appProperties?;
    @display{label: "Content Hints"}
    ContentHints contentHints?;
    @display{label: "Copy Operation Needs Writers Permission"}
    boolean copyRequiresWriterPermission?;
    @display{label: "Modified Time"}
    string modifiedTime?;
    @display{label: "Original File Name"}
    string originalFilename?;
    @display{label: "Properties"}
    StringKeyValuePairs properties?;
    @display{label: "Last Time File Viewed"}
    string viewedByMeTime?;
    @display{label: "Only Writers Can Modify"}
    boolean writersCanShare?;
};

# Represents generated file metadata
#
# + id - The ID of the file/folder
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#file"
# + owners - The owners of the file. Currently, only certain legacy files may have more than one owner. Not populated 
#            for items in shared drives 
# + contentRestrictions - Restrictions for accessing the content of the file. Only populated if such a restriction 
#                         exists
# + version - A monotonically increasing version number for the file. This reflects every change made to the file on 
#             the server, even those not visible to the user
# + iconLink - A static, unauthenticated link to the file's icon
# + permissions - The full list of permissions for the file. This is only available if the requesting user can share 
#                 the file.  Not populated for items in shared drives
# + isAppAuthorized - Whether the file was created or opened by the requesting app
# + createdTime - The time at which the file was created (RFC 3339 date-time)
# + sharedWithMeTime - The time at which the file was shared with the user, if applicable (RFC 3339 date-time).
#                     Not populated for items in shared drives
# + webViewLink - A link for opening the file in a relevant Google editor or viewer in a browser
# + ownedByMe - Whether the user owns the file. Not populated for items in shared drives
# + explicitlyTrashed - Whether the file has been explicitly trashed, 
#                       as opposed to recursively trashed from a parent folder
# + trashedTime - The time that the item was trashed (RFC 3339 date-time). Only populated for items in shared drives  
# + viewedByMe - Whether the file has been viewed by this user
# + driveId - ID of the shared drive the file resides in. Only populated for items in shared drives  
# + size - The size of the file's content in bytes. 
#          This is applicable to binary files in Google Drive and Google Docs files    
# + spaces - The list of spaces which contain the file. The currently supported values are 'drive', 
#            'appDataFolder' and 'photos'
# + imageMediaMetadata - Additional metadata about image media, if available
# + parents - The IDs of the parent folders which contain the file. If not specified as part of a create request, 
#             the file will be placed directly in the user's My Drive folder. 
#             If not specified as part of a copy request, 
#             the file will inherit any discoverable parents of the source file
#             Update requests must use the addParents and removeParents parameters to modify the parents list. 
# + headRevisionId - The ID of the file's head revision. This is currently only available for files with binary content 
#                    in Google Drive
# + modifiedByMeTime - The last time the file was modified by the user (RFC 3339 date-time)
# + modifiedByMe - Whether the file has been modified by this user
# + shared - Whether the file has been shared. Not populated for items in shared drives 
# + hasAugmentedPermissions - Whether there are permissions directly on this file. 
#                             This field is only populated for items in shared drives   
# + trashingUser - If the file has been explicitly trashed, the user who trashed it. Only populated for items in shared 
#                  drives
# + thumbnailLink - A short-lived link to the file's thumbnail, if available. Typically lasts on the order of hours. 
#                   Only populated when the requesting app can access the file's content. 
#                   If the file isn't shared publicly, the URL returned in Files.thumbnailLink must be fetched using 
#                   a credentialed request
# + permissionIds - List of permission IDs for users with access to this file
# + quotaBytesUsed - The number of storage quota bytes used by the file.  This includes the head revision as well as 
#                    previous revisions with keepForever enabled 
# + lastModifyingUser - The last user to modify the file
# + md5Checksum - The MD5 checksum for the content of the file. This is only applicable to files with binary content
#                 in Google Drive
# + fileExtension - The final component of fullFileExtension. This is only available for files with binary content 
#                   in Google Drive
# + fullFileExtension - The full file extension extracted from the name field.  May contain multiple concatenated 
#                       extensions, such as "tar.gz".This is only available for files with binary content in Google 
#                       Drive
# + webContentLink - A link for downloading the content of the file in a browser. This is only available for files with 
#                    binary content in Google Drive
# + shortcutDetails - Shortcut file details.Only populated for shortcut files, which have the mimeType field set to 
#                     application/vnd.google-apps.shortcut  
# + hasThumbnail - Whether this file has a thumbnail. This does not indicate whether the requesting app has access 
#                  to the thumbnail.To check access,look for the presence of the thumbnailLink field
# + capabilities - Capabilities the current user has on this file.  Each capability corresponds to a fine-grained 
#                  action that a user may take
# + videoMediaMetadata - Additional metadata about video media. This may not be available immediately upon upload 
# + thumbnailVersion - The thumbnail version for use in thumbnail cache invalidation
# + exportLinks - Links for exporting Docs Editors files to specific formats
# + sharingUser - The user who shared the file with the requesting user, if applicable
public type GeneratedFileMetadata record {
    string id?;
    string kind?;
    boolean explicitlyTrashed?;
    User trashingUser?;
    string trashedTime?;
    string[] parents?;
    string[] spaces?;
    int 'version?;
    string webContentLink?;
    string webViewLink?;
    string iconLink?;
    boolean hasThumbnail?;
    string thumbnailLink?;
    int thumbnailVersion?;
    boolean viewedByMe?;
    boolean modifiedByMe?;
    string createdTime?;
    string modifiedByMeTime?;
    string sharedWithMeTime?;
    User sharingUser?;
    User[] owners?;
    string driveId?;
    User lastModifyingUser?;
    boolean shared?;
    boolean ownedByMe?;
    Capabilities capabilities?;
    Permissions[] permissions?;
    string[] permissionIds?;
    boolean hasAugmentedPermissions?;
    string fullFileExtension?;
    string fileExtension?;
    string md5Checksum?;
    int size?; 
    int quotaBytesUsed?;
    string headRevisionId?;
    ImageMediaMetadata imageMediaMetadata?;
    VideoMediaMetadata videoMediaMetadata?;
    boolean isAppAuthorized?;
    StringKeyValuePairs exportLinks?;
    ShortcutDetails shortcutDetails?;
    ContentRestrictions contentRestrictions?;
};
 
# Record Type to accpet string values.  
public type StringKeyValuePairs record {|
    string...;
|};

# Record Type to accept string[] values.
public type StringArrayValuePairs record {|
    string[]...;
|};

# Record Type to accept float values.
public type StorageQuota record {|
    float...;
|};

# Restrictions for accessing the content of the file. Only populated if such a restriction exists.
#
# + reason - Reason for why the content of the file is restricted. This is only mutable on requests that also 
#            set readOnly=true
# + readOnly - Whether the content of the file is read-only. If a file is read-only, a new revision of the file may not 
#              be added,comments may not be added or modified, and the title of the file may not be modified
# + restrictionTime - The time at which the content restriction was set (formatted RFC 3339 timestamp)
#                     Only populated if readOnly is true
# + type - The type of the content restriction. Currently the only possible value is globalContentRestriction
# + restrictingUser - The user who set the content restriction. Only populated if readOnly is true
public type ContentRestrictions record {
    boolean readOnly;
    string reason;
    User restrictingUser;
    string restrictionTime;
    string 'type;
};

# Shortcut file details. Only populated for shortcut files, 
# which have the mimeType field set to application/vnd.google-apps.shortcut.
#
# + targetId - The ID of the file that this shortcut points to 
# + targetMimeType - The MIME type of the file that this shortcut points to. The value of this field is a snapshot of 
#                    the target's MIME type, captured when the shortcut is created
public type ShortcutDetails record {
    string targetId;
    string targetMimeType;
};

# Additional metadata about video media. This may not be available immediately upon upload.
#
# + width - The width of the video in pixelsn  
# + durationMillis - The duration of the video in milliseconds
# + height - The height of the video in pixels
public type VideoMediaMetadata record {
    int width;
    int height;
    float durationMillis;
};

# Additional metadata about image media, if available
#
# + meteringMode - The metering mode used to create the photo
# + exposureTime - The length of the exposure in seconds
# + whiteBalance - The white balance mode used to create the photo
# + rotation - The number of clockwise 90 degree rotations applied from the image's original orientation
# + maxApertureValue - The smallest f-number of the lens at the focal length used to create the photo (APEX value)
# + lens - The lens used to create the photo
# + exposureBias - The exposure bias of the photo (APEX value)
# + colorSpace - The color space of the photo
# + aperture - The aperture used to create the photo (f-number)
# + flashUsed - Whether a flash was used to create the photo
# + subjectDistance - The distance to the subject of the photo, in meters
# + width - The width of the video in pixels
# + cameraModel - The model of the camera used to create the photo	
# + location - Geographic location information stored in the image
# + isoSpeed - The ISO speed used to create the photo
# + sensor - The type of sensor used to create the photo
# + time - The date and time the photo was taken (EXIF DateTime)
# + cameraMake - The make of the camera used to create the photo
# + exposureMode - The length of the exposure, in seconds
# + height - The height of the image in pixels
# + focalLength - The focal length used to create the photo, in millimeters
public type ImageMediaMetadata record {
    int width;
    int height;
    int rotation;
    Location location;
    string time;
    string cameraMake;
    string cameraModel;
    int exposureTime;
    int aperture;
    boolean flashUsed;
    int focalLength;
    int isoSpeed;
    string meteringMode;
    string sensor;
    string exposureMode;
    string colorSpace;
    string whiteBalance;
    int exposureBias;
    int maxApertureValue;
    int subjectDistance;
    string lens;
};

# Geographic location information stored in the image.
#
# + altitude - The altitude stored in the image
# + latitude - The latitude stored in the image
# + longitude - The longitude stored in the image
public type Location record {
    float latitude; 
    float longitude; 
    float altitude;
};

# Additional information about the content of the file. These fields are never populated in responses.
#
# + thumbnail - A thumbnail for the file. This will only be used if Google Drive cannot generate a standard thumbnail
# + indexableText - Text to be indexed for the file to improve fullText queries.
#                   This is limited to 128KB in length and may contain HTML elements
public type ContentHints record {
    Thumbnail thumbnail;
    string indexableText;
};

# A thumbnail for the file. This will only be used if Google Drive cannot generate a standard thumbnail.
#
# + image - The thumbnail data encoded with URL-safe Base64 (RFC 4648 section 5)
# + mimeType - The MIME type of the thumbnail
public type Thumbnail record {
    byte image;
    string mimeType;
};

# Response from file search 
#
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#fileList"
# + nextPageToken - The page token for the next page of files.
#                   This will be absent if the end of the files list has been reached.
#                   If the token is rejected for any reason, it should be discarded, 
#                   and pagination should be restarted from the first page of results
# + files - The list of files.
#           If nextPageToken is populated, 
#           then this list may be incomplete and an additional page of results should be fetched. 
# + incompleteSearch - Whether the search process was incomplete. If true, then some search results may be missing, 
#                      Since all documents were not searched. This may occur when searching multiple drives with the 
#                      "allDrives" corpora, but all corpora could not be searched. When this happens, it is suggested 
#                      that clients narrow their query by choosing a different corpus such as "user" or "drive".  
public type FilesResponse record {
    string kind;
    string nextPageToken?;
    boolean incompleteSearch?;
    File[] files;
};

# Optional query parameters in get files.
#
# + acknowledgeAbuse - Whether the user is acknowledging the risk of downloading known malware or other abusive files. 
#                      This is only applicable when alt=media. (Default: false)  
# + includePermissionsForView - Specifies which additional view's permissions to include in the response. 
#                               Only 'published' is supported
# + alt -  If you provide the URL parameter alt=media, then the response includes the file contents in the response body
# + fields - The paths of the fields you want included in the response. 
#            If not specified, the response includes a default set of fields specific to this method. For development 
#            you can use the special value * to return all fields, but you'll achieve greater performance by only 
#            selecting the fields you need  
# + supportsAllDrives - Whether the requesting application supports both My Drives and shared drives. (Default: false)  
public type GetFileOptional record {
    boolean acknowledgeAbuse?;
    string fields?;
    string alt?;
    string includePermissionsForView?;
    boolean? supportsAllDrives = true;
};

# Optional query parameters in delete files.
# Permanently deletes a file owned by the user without moving it to the trash. 
#
# + supportsAllDrives - Whether the requesting application supports both My Drives and shared drives. (Default: false)  
type DeleteFileOptional record {
    boolean? supportsAllDrives = true;
};

# Optional query parameters in copy files.
# Creates a copy of a file and applies any requested updates with patch semantics. Folders cannot be copied.
#
# + ocrLanguage - A language hint for OCR processing during image import (ISO 639-1 code)
# + keepRevisionForever -  Whether to set the 'keepForever' field in the new head revision. 
#                          This is only applicable to files with binary content in Google Drive. 
#                          Only 200 revisions for the file can be kept forever. If the limit is reached,
#                          try deleting pinned revisions. (Default: false)
# + ignoreDefaultVisibility - Whether to ignore the domain's default visibility settings for the created file. 
#                             Domain administrators can choose to make all uploaded files 
#                             visible to the domain by default; 
#                             this parameter bypasses that behavior for the request. 
#                             Permissions are still inherited from parent folders. (Default: false) 
# + includePermissionsForView - Specifies which additional view's permissions to include in the response. 
#                               Only 'published' is supported
# + fields - The paths of the fields you want included in the response. 
#            If not specified, the response includes a default set of fields 
#            specific to this method. For development you can use the special value * to return all fields, 
#            but you'll achieve greater performance by only selecting the fields you need   
# + supportsAllDrives -   Whether the requesting application supports both My Drives and shared drives.(Default: false)
type CopyFileOptional record {
    string fields?;
    boolean ignoreDefaultVisibility?;
    string includePermissionsForView?;
    boolean keepRevisionForever?;
    string ocrLanguage?;
    boolean supportsAllDrives;
};

# Optional query parameters in create files.
#
# + ocrLanguage - A language hint for OCR processing during image import (ISO 639-1 code).
# + keepRevisionForever - Whether to set the 'keepForever' field in the new head revision. 
#                         This is only applicable to files with binary content in Google Drive. 
#                         Only 200 revisions for the file can be kept forever. If the limit is reached,
#                         try deleting pinned revisions. (Default: false)
# + useContentAsIndexableText - Whether to use the uploaded content as indexable text. (Default: false)
# + ignoreDefaultVisibility - Whether to ignore the domain's default visibility settings for the created file. 
#                             Domain administrators can choose to make all uploaded files visible to the 
#                             domain by default; 
#                             this parameter bypasses that behavior for the request. 
#                             Permissions are still inherited from parent folders. (Default: false) 
# + uploadType - The type of upload request to the /upload URI. If you are uploading data (using an /upload URI), 
#                More details : https://developers.google.com/drive/api/v3/reference/files/create
# + includePermissionsForView - Specifies which additional view's permissions to include in the response. 
#                               Only 'published' is supported 
# + supportsAllDrives - Whether the requesting application supports both My Drives and shared drives. (Default: false)
type CreateFileOptional record {
    never uploadType?; 
    boolean ignoreDefaultVisibility?;
    string includePermissionsForView?; 
    boolean keepRevisionForever?; 
    string ocrLanguage?;  
    boolean supportsAllDrives?; 
    boolean useContentAsIndexableText?; 
};

# Update file optional parameters.
#
# + ocrLanguage - A language hint for OCR processing during image import (ISO 639-1 code)
# + removeParents - A comma-separated list of parent IDs to remove
# + keepRevisionForever - Whether to set the 'keepForever' field in the new head revision. 
#                         This is only applicable to files with binary content in Google Drive. 
#                         Only 200 revisions for the file can be kept forever. If the limit is reached,
#                         try deleting pinned revisions. (Default: false)
# + useContentAsIndexableText - Whether to use the uploaded content as indexable text. (Default: false)
# + includePermissionsForView - Specifies which additional view's permissions to include in the response. 
#                               Only 'published' is supported
# + addParents - A comma-separated list of parent IDs to add
# + supportsAllDrives -  Whether the requesting application supports both My Drives and shared drives. (Default: false)  
@display {label: "File Metadata"}
public type UpdateFileMetadataOptional record {
    @display {label: "Add Parents"}
    string addParents?; 
    @display {label: "Include Permissions for View"}
    string includePermissionsForView?; 
    @display {label: "Keep Revision Forever"}
    boolean keepRevisionForever?; 
    @display {label: "OCR Language hint"}
    string ocrLanguage?; 
    @display {label: "Remove Parents"}
    string removeParents?;
    @display {label: "Supports All Drives"} 
    boolean supportsAllDrives?;
    @display {label: "Use Uploaded Content as Indexable Text"} 
    boolean useContentAsIndexableText?; 
};

# Represents User.
#
# + permissionId - The user's ID as visible in Permission resources  
# + emailAddress - The email address of the user. This may not be present in certain contexts if the user has not made. 
#                   their email address visible to the requester
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#user".
# + displayName - A plain text displayable name for this user
# + me - Whether this user is the requesting user 
# + photoLink - A link to the user's profile photo, if available
public type User record {
    string kind?;
    string displayName?;
    string photoLink?;
    boolean me?;
    string permissionId?;
    string emailAddress?;
};

# Capabilities the current user has on this file. 
# Each capability corresponds to a fine-grained action that a user may take.
#
# + canReadRevisions - Whether the current user can read the revisions resource of this file. For a shared drive item, 
#                      whether revisions of non-folder descendants of this item, 
#                        or this item itself if it is not a folder, can be read
# + canMoveItemOutOfDrive - Whether the current user can move this item outside of this drive by changing its parent. 
#                           Note that a request to change the parent of the item may still fail depending on the new 
#                           parent that is being added
# + canEdit - Whether the current user can edit this file. 
#             Other factors may limit the type of changes a user can make to a file. 
#             For example, see canChangeCopyRequiresWriterPermission or canModifyContent
# + canRename - Whether the current user can rename this file
# + canAddMyDriveParent - Whether the current user can add a parent for the item without removing 
#                         an existing parent in the same request. 
#                         Not populated for shared drive files
# + canTrashChildren - Whether the current user can trash children of this folder. 
#                      This is false when the item is not a folder. 
#                      Only populated for items in shared drives
# + canAddChildren - Whether the current user can add children to this folder. 
#                    This is always false when the item is not a folder
# + canListChildren -  Whether the current user can list the children of this folder. 
#                      This is always false when the item is not a folder
# + canTrash - Whether the current user can move this file to trash
# + canRemoveMyDriveParent - Whether the current user can remove a parent from the item without adding 
#                            another parent in the same request. 
#                            Not populated for shared drive files
# + canCopy - Whether the current user can copy this file. For an item in a shared drive, 
#             whether the current user can copy non-folder 
#             descendants of this item, or this item itself if it is not a folder
# + canDownload - Whether the current user can download this file
# + canDelete - Whether the current user can delete this file
# + canAddFolderFromAnotherDrive - Whether the current user can add a folder from 
#                                  another drive (different shared drive or My Drive) to this folder. 
#                                  This is false when the item is not a folder. Only populated for items 
#                                  in shared drives
# + canComment - Whether the current user can comment on this file
# + canUntrash - Whether the current user can restore this file from trash
# + canMoveChildrenWithinDrive - Whether the current user can move children of this folder within this drive. 
#                                This is false when the item is not a folder. 
#                                Note that a request to move the child may still fail depending on the 
#                                current user's access to the child and to the destination folder
# + canModifyContentRestriction - Whether the current user can modify restrictions on content of this file  
# + canChangeCopyRequiresWriterPermission - Whether the current user can change the copyRequiresWriterPermission 
#                                           restriction of this file
# + canMoveChildrenOutOfDrive - Whether the current user can move children of this folder outside of the shared drive. 
#                               This is false when the item is not a folder.Only populated for items in shared drives. 
# + canReadDrive - Whether the current user can read the shared drive to which this file belongs
#                  Only populated for items in shared drives
# + canDeleteChildren - Whether the current user can delete children of this folder. 
#                       This is false when the item is not a folder. 
#                       Only populated for items in shared drives
# + canMoveItemWithinDrive - Whether the current user can move this item within this drive. 
#                            Note that a request to change the parent of the item may still fail 
#                            depending on the new parent that is being added and the parent that is being removed
# + canModifyContent - Whether the current user can modify the content of this file
# + canRemoveChildren - Whether the current user can remove children from this folder. This is always false when the 
#                       item is not a folder. For a folder in a shared drive, use canDeleteChildren or canTrashChildren 
#                       instead
# + canShare - Whether the current user can modify the sharing settings for this file
public type Capabilities record {
    boolean	canAddChildren;
    boolean canAddFolderFromAnotherDrive;
    boolean canAddMyDriveParent;
    boolean canChangeCopyRequiresWriterPermission;
    boolean canComment;
    boolean canCopy;
    boolean canDelete;
    boolean canDeleteChildren;
    boolean canDownload;
    boolean canEdit;
    boolean canListChildren;
    boolean canModifyContent;
    boolean canModifyContentRestriction;
    boolean canMoveChildrenOutOfDrive;
    boolean canMoveChildrenWithinDrive;
    boolean canMoveItemOutOfDrive;
    boolean canMoveItemWithinDrive;
    boolean canReadRevisions;
    boolean canReadDrive;
    boolean canRemoveChildren;
    boolean canRemoveMyDriveParent;
    boolean canRename;
    boolean canShare;
    boolean canTrash;
    boolean canTrashChildren;
    boolean canUntrash;
};

# A permission for a file. 
# A permission grants a user, group, domain or the world access to a file or a folder hierarchy.
#
# + role - The role granted by this permission
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#permission"
# + displayName - The "pretty" name of the value of the permission
# + emailAddress - The email address of the user or group to which this permission refers
# + view - Indicates the view for this permission.
#          Only populated for permissions that belong to a view. published is the only supported value
# + deleted - Whether the account associated with this permission has been deleted.
#             This field only pertains to user and group permissions
# + permissionDetails - Details of whether the permissions on this shared drive item 
#                       are inherited or directly on this item 
#                       This is an output-only field which is present only for shared drive items.
# + expirationTime - The time at which this permission will expire (RFC 3339 date-time)
# + domain - The domain to which this permission refers
# + id - The ID of this permission. This is a unique identifier for the grantee, 
#        and is published in User resources as permissionId. 
#        IDs should be treated as opaque values
# + photoLink - A link to the user's profile photo, if available
# + type - The type of the grantee  
# + allowFileDiscovery - Whether the permission allows the file to be discovered through search. 
#                        This is only applicable for permissions of type domain or anyone
public type Permissions record {
    string kind;
    string id;
    string 'type;
    string emailAddress;
    string domain;
    string role;
    string view;
    boolean allowFileDiscovery;
    string displayName;
    string photoLink;
    string expirationTime;
    PermissionDetails[] permissionDetails?;
    boolean deleted;
};

# Details of whether the permissions on this shared drive item are inherited or directly on this item. 
# This is an output-only field which is present only for shared drive items.
#
# + permissionType - The permission type for this user
# + role - The primary role for this user
# + inherited - Whether this permission is inherited. This field is always populated. This is an output-only field  
# + inheritedFrom - The ID of the item from which this permission is inherited. This is an output-only field
public type PermissionDetails record {
    string permissionType;
    string role;
    string inheritedFrom;
    boolean inherited;
};

# Optionals used in Lists or searches files.
#
# + includeItemsFromAllDrives - Whether both My Drive and shared drive items. 
#                               should be included in results. (Default: false) 
# + q - A query for filtering the file results. See the "Search for files" guide for the supported syntax.
#       https://developers.google.com/drive/api/v3/search-files
# + driveId - ID of the shared drive to search
# + spaces - A comma-separated list of spaces to query within the corpus. 
#             Supported values are 'drive', 'appDataFolder' and 'photos'
# + corpora - Groupings of files to which the query applies. 
#             Supported groupings are: 'user' (files created by, opened by, or shared directly with the user),
#             'drive' (files in the specified shared drive as indicated by the 'driveId'), 
#             'domain' (files shared to the user's domain), and 'allDrives' 
#             (A combination of 'user' and 'drive' for all drives where the user is a member). 
#             When able, use 'user' or 'drive', instead of 'allDrives', for efficiency
# + includePermissionsForView - Specifies which additional view's permissions to include in the response. 
#                               Only 'published' is supported
# + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 
#             'modifiedByMeTime', 'modifiedTime', 'name', 
#            'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', and 'viewedByMeTime'. 
#             Each key sorts ascending by default, but may be reversed with the 'desc' modifier   
# + pageSize - The maximum number of files to return per page
#              Partial or empty result pages are possible even before the end of the files list has been reached
#              Acceptable values are 1 to 1000, inclusive. (Default: 100)
# + pageToken - The token for continuing a previous list request on the next page
#               This should be set to the value of 'nextPageToken' from the previous response
# + fields - The paths of the fields you want included in the response
#            If not specified, the response includes a default set of fields specific to this method.
# + supportsAllDrives -  Whether the requesting application supports both My Drives and shared drives. (Default: false) 
type ListFilesOptional record {
    string corpora?; 
    string driveId?;
    string fields?; 
    boolean includeItemsFromAllDrives?; 
    string includePermissionsForView?;  
    string orderBy?; 
    int pageSize?; 
    string pageToken?;
    string q?;
    string spaces?;
    boolean supportsAllDrives?;
};

# Mime types for file operations.
# 
# + DOCS - Google documents MIME type
# + SHEETS - Google spreadsheets MIME type
# + SLIDES - Google presentations MIME type
# + FORMS - Google Forms MIME type
# + AUDIO - Audio MIME type
# + DRIVE_SDK - Drive SDK MIME type
# + DRAWING - Drawing MIME type
# + FILE - File MIME type
# + FUSIONTABLE - Fusiontable MIME type
# + MAP - Map MIME type
# + PHOTO - Photo MIME type
# + SCRIPT - Script MIME type
# + SHORTCUT - Shortcut MIME type
# + SITE - Site MIME type
# + UNKNOWN - Unknown MIME type
# + VIDEO - Video MIME type
public enum MimeTypes {
    DOCUMENT = "application/vnd.google-apps.document",
    SPREADSHEET = "application/vnd.google-apps.spreadsheet",
    PRESENTATION = "application/vnd.google-apps.presentation",
    FORM = "application/vnd.google-apps.form",
    AUDIO = "application/vnd.google-apps.audio",
    DRIVE_SDK = "application/vnd.google-apps.drive-sdk",
    DRAWING = "application/vnd.google-apps.drawing",
    FILE = "application/vnd.google-apps.file",
    FUSIONTABLE = "application/vnd.google-apps.fusiontable",
    MAP = "application/vnd.google-apps.map",
    PHOTO = "application/vnd.google-apps.photo",
    SCRIPT = "application/vnd.google-apps.script",
    SHORTCUT = "application/vnd.google-apps.shortcut",
    SITE = "application/vnd.google-apps.site",
    UNKNOWN = "application/vnd.google-apps.unknown",
    VIDEO = "application/vnd.google-apps.video"
}
 
# Represents file content.
#
# + content - A `byte[]` which represents the content of a file
# + mimeType - The MIME type for the file
public type FileContent record {
    byte[] content;
    string mimeType;
};

# A change to a file or shared drive.
#
# + changeType - The type of the change. Possible values are file and drive.
# + drive - Drive the file or shared drive belongs to.
# + driveId - The ID of the shared drive associated with this change.
# + file - The file which has changed. This will only be populated if the file is still accessible to the user.
# + fileId - The ID of the file which has changed.
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#change".
# + removed - Whether the file or shared drive has been removed from this list of changes,
# for example by deletion or loss of access.
# + time - The time of this change (RFC 3339 date-time).
public type Change record {
    string changeType?;
    Drive drive?;
    string driveId?;
    File file?;
    string fileId?;
    string kind = "drive#change";
    boolean removed?;
    string time?;
};

# A list of changes for a user.
#
# + changes - The list of changes. If nextPageToken is populated, then this list may be incomplete and an additional page of results should be fetched.
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#changeList".
# + newStartPageToken - The starting page token for future changes. This will be present only if the end of the current changes list has been reached.
# + nextPageToken - The page token for the next page of changes. This will be absent if the end of the changes list has been reached. If the token is rejected for any reason, it should be discarded, and pagination should be restarted from the first page of results.
public type ChangeList record {
    Change[] changes;
    string kind = "drive#changeList";
    string newStartPageToken?;
    string nextPageToken?;
};

# Representation of a shared drive.
#
# + backgroundImageFile - Drive background image file details.
# + backgroundImageLink - A short-lived link to this shared drive's background image.
# + capabilities - Capabilities the current user has on this shared drive.
# + colorRgb - The color of this shared drive as an RGB hex string. It can only be set on drive.drives.update requests that don't set themeId.
# + createdTime - The time at which the shared drive was created (RFC 3339 date-time).
# + hidden - Whether this shared drive is hidden from default view.
# + id - The ID of this shared drive which is also the ID of the top level folder of this shared drive.
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#drive".
# + name - The name of this shared drive.
# + orgUnitId - The organizational unit of this shared drive. This field is only populated on drives.list responses when the useDomainAdminAccess parameter is set to true.
# + restrictions - Restrictions for accessing the content of the shared drive. This field is only populated on drives.get responses.
# + themeId - The ID of the theme from which the background image and color are set. The set of possible driveThemes can be retrieved from a drive.about.get response. When not specified on a drive.drives.create request, a random theme is chosen from which the background image and color are set. This is a write-only field; it can only be set on requests that don't set colorRgb or backgroundImageFile.
public type Drive record {
    DriveBackgroundImageFile backgroundImageFile?;
    string backgroundImageLink?;
    DriveCapabilities capabilities?;
    string colorRgb?;
    string createdTime?;
    boolean hidden?;
    string id?;
    string kind = "drive#drive";
    string name?;
    string orgUnitId?;
    DriveRestrictions restrictions?;
    string themeId?;
};

# Description.
#
# + pageSize - field description
# + includeItemsFromAllDrives - field description
# + includeRemoved - field description
# + includeCorpusRemovals - field description
# + restrictToMyDrive - field description
# + driveId - field description
# + fields - field description
# + supportsAllDrives - field description
public type ListChangesOptional record {
    int pageSize?; // 1‑1000 (default 100)
    boolean includeItemsFromAllDrives?; // Default false
    boolean includeRemoved?; // Default false
    boolean includeCorpusRemovals?; // Default false
    boolean restrictToMyDrive?; // Default false
    string driveId?;
    string fields?;
    boolean supportsAllDrives?; // Default false
};

# An image file and cropping parameters from which a background image for this shared drive is set. This is a write-only field; it can only be set on drive.drives.update requests that don't set themeId. When specified, all fields of the backgroundImageFile must be set.
#
# + id - The ID of an image file in Google Drive to use for the background image.
# + width - The width of the cropped image in the closed range of 0 to 1. This value represents the width of the cropped image divided by the width of the entire image. The height is computed by applying a width to height aspect ratio of 80 to 9. The resulting image must be at least 1280 pixels wide and 144 pixels high.
# + xCoordinate - The X coordinate of the upper left corner of the cropping area in the background image. This is a value in the closed range of 0 to 1. This value represents the horizontal distance from the left side of the entire image to the left side of the cropping area divided by the width of the entire image.
# + yCoordinate - The Y coordinate of the upper left corner of the cropping area in the background image. This is a value in the closed range of 0 to 1. This value represents the vertical distance from the top side of the entire image to the top side of the cropping area divided by the height of the entire image.
public type DriveBackgroundImageFile record {
    string id?;
    float width?;
    float xCoordinate?;
    float yCoordinate?;
};

# Capabilities the current user has on this shared drive.
#
# + canAddChildren - Whether the current user can add children to folders in this shared drive.
# + canChangeCopyRequiresWriterPermissionRestriction - Whether the current user can change the copyRequiresWriterPermission restriction of this shared drive.
# + canChangeDomainUsersOnlyRestriction - Whether the current user can change the domainUsersOnly restriction of this shared drive.
# + canChangeDriveBackground - Whether the current user can change the background of this shared drive.
# + canChangeDriveMembersOnlyRestriction - Whether the current user can change the driveMembersOnly restriction of this shared drive.
# + canChangeSharingFoldersRequiresOrganizerPermissionRestriction - Whether the current user can change the sharingFoldersRequiresOrganizerPermission restriction of this shared drive.
# + canComment - Whether the current user can comment on files in this shared drive.
# + canCopy - Whether the current user can copy files in this shared drive.
# + canDeleteChildren - Whether the current user can delete children from folders in this shared drive.
# + canDeleteDrive - Whether the current user can delete this shared drive. Attempting to delete the shared drive may still fail if there are untrashed items inside the shared drive.
# + canDownload - Whether the current user can download files in this shared drive.
# + canEdit - Whether the current user can edit files in this shared drive
# + canListChildren - Whether the current user can list the children of folders in this shared drive.
# + canManageMembers - Whether the current user can add members to this shared drive or remove them or change their role.
# + canReadRevisions - Whether the current user can read the revisions resource of files in this shared drive.
# + canRename - Whether the current user can rename files or folders in this shared drive.
# + canRenameDrive - Whether the current user can rename this shared drive.
# + canResetDriveRestrictions - Whether the current user can reset the shared drive restrictions to defaults.
# + canShare - Whether the current user can share files or folders in this shared drive.
# + canTrashChildren - Whether the current user can trash children from folders in this shared drive.
public type DriveCapabilities record {
    boolean canAddChildren?;
    boolean canChangeCopyRequiresWriterPermissionRestriction?;
    boolean canChangeDomainUsersOnlyRestriction?;
    boolean canChangeDriveBackground?;
    boolean canChangeDriveMembersOnlyRestriction?;
    boolean canChangeSharingFoldersRequiresOrganizerPermissionRestriction?;
    boolean canComment?;
    boolean canCopy?;
    boolean canDeleteChildren?;
    boolean canDeleteDrive?;
    boolean canDownload?;
    boolean canEdit?;
    boolean canListChildren?;
    boolean canManageMembers?;
    boolean canReadRevisions?;
    boolean canRename?;
    boolean canRenameDrive?;
    boolean canResetDriveRestrictions?;
    boolean canShare?;
    boolean canTrashChildren?;
};

# A set of restrictions that apply to this shared drive or items inside this shared drive.
#
# + adminManagedRestrictions - Whether administrative privileges on this shared drive are required to modify restrictions.
# + copyRequiresWriterPermission - Whether the options to copy, print, or download files inside this shared drive, should be disabled for readers and commenters. When this restriction is set to true, it will override the similarly named field to true for any file inside this shared drive.
# + domainUsersOnly - Whether access to this shared drive and items inside this shared drive is restricted to users of the domain to which this shared drive belongs. This restriction may be overridden by other sharing policies controlled outside of this shared drive.
# + driveMembersOnly - Whether access to items inside this shared drive is restricted to its members.
# + sharingFoldersRequiresOrganizerPermission - If true, only users with the organizer role can share folders. If false, users with either the organizer role or the file organizer role can share folders.
public type DriveRestrictions record {
    boolean adminManagedRestrictions?;
    boolean copyRequiresWriterPermission?;
    boolean domainUsersOnly?;
    boolean driveMembersOnly?;
    boolean sharingFoldersRequiresOrganizerPermission?;
};
