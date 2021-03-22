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

# Represents configuration parameters to create Google drive Client.
#
# + secureSocketConfig - Represents OAuth2 direct token configurations for OAuth2 authentication 
# + clientConfig - Provides configurations for facilitating secure communication with a remote HTTP endpoint  
public type Configuration record {
    http:BearerTokenConfig|http:OAuth2RefreshTokenGrantConfig clientConfig; 
    http:ClientSecureSocket secureSocketConfig?;
};

# Drive Info Record Type
#
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#about".  
# + user - The authenticated user.
# + storageQuota - The user's storage quota limits and usage. All fields are measured in bytes
# + importFormats - A map of source MIME type to possible targets for all supported imports.
# + exportFormats - A map of source MIME type to possible targets for all supported exports.
# + maxImportSizes - A map of maximum import sizes by MIME type, in bytes.
# + maxUploadSize - The maximum upload size in bytes.
# + appInstalled - Whether the user has installed the requesting app.
# + folderColorPalette - The currently supported folder colors as RGB hex strings.
# + driveThemes - A list of themes that are supported for shared drives.
# + canCreateDrives - Whether the user can create shared drives.
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

# File Record Type
#
# + modifiedTime - The last time the file was modified by anyone (RFC 3339 date-time)  
# + copyRequiresWriterPermission - Whether the options to copy, print, or download this file, should be disabled for 
#                                  readers and commenters 
# + owners - The owners of the file. Currently, only certain legacy files may have more than one owner. Not populated 
#            for items in shared drives.  
# + mimeType - The MIME type of the file.Google Drive will attempt to automatically detect an appropriate value. 
#              from uploaded content if no value is provided.  The value cannot be changed unless a new revision 
#              is uploaded.
#              If a file is created with a Google Doc MIME type, the uploaded content will be imported if possible. 
#              The supported import formats are published in the About resource.  
# + contentRestrictions - Restrictions for accessing the content of the file. Only populated if such a restriction 
#                         exists.  
# + version - A monotonically increasing version number for the file. This reflects every change made to the file on 
#             the server, even those not visible to the user.  
# + iconLink - A static, unauthenticated link to the file's icon. 
# + starred - Whether the user has starred the file.  
# + permissions - The full list of permissions for the file. This is only available if the requesting user can share 
#                 the file.  Not populated for items in shared drives. 
# + contentHints - Additional information about the content of the file. These fields are never populated in responses  
# + isAppAuthorized - Whether the file was created or opened by the requesting app.  
# + createdTime - The time at which the file was created (RFC 3339 date-time).  
# + id - The ID of the file/folder.  
# + sharedWithMeTime - The time at which the file was shared with the user, if applicable (RFC 3339 date-time).  
# + writersCanShare - Whether users with only writer permission can modify the file's permissions. 
#                     Not populated for items in shared drives.  
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#file".   
# + webViewLink - A link for opening the file in a relevant Google editor or viewer in a browser. 
# + ownedByMe - Whether the user owns the file. Not populated for items in shared drives.  
# + explicitlyTrashed - Whether the file has been explicitly trashed, 
#                       as opposed to recursively trashed from a parent folder.  
# + trashedTime - The time that the item was trashed (RFC 3339 date-time). Only populated for items in shared drives.  
# + viewedByMe - Whether the file has been viewed by this user.  
# + driveId - ID of the shared drive the file resides in. Only populated for items in shared drives  
# + size - The size of the file's content in bytes. 
#          This is applicable to binary files in Google Drive and Google Docs files.  
# + name - The name of the file. This is not necessarily unique within a folder. 
#          Note that for immutable items such as the top level folders of shared drives, My Drive root folder, and 
#          Application Data folder the name is constant.  
# + spaces - The list of spaces which contain the file. The currently supported values are 'drive', 
#            'appDataFolder' and 'photos'.  
# + imageMediaMetadata - Additional metadata about image media, if available.  
# + trashed - Whether the file has been trashed, either explicitly or from a trashed parent folder. Only the owner may 
#             trash a file. The trashed item is excluded from all files.
#             list responses returned for any user who does not own the file. 
#             However, all users with access to the file can see the trashed item metadata in an API response. 
#             All users with access can copy, download, export, and share the file.  
# + parents - The IDs of the parent folders which contain the file. If not specified as part of a create request, 
#             the file will be placed directly in the user's My Drive folder. 
#             If not specified as part of a copy request, 
#             the file will inherit any discoverable parents of the source file. 
#             Update requests must use the addParents and removeParents parameters to modify the parents list.
# + appProperties - A collection of arbitrary key-value pairs which are private to the requesting app.  
# + folderColorRgb - The color for a folder as an RGB hex string. 
#                    The supported colors are published in the folderColorPalette field of the About resource.  
# + headRevisionId - The ID of the file's head revision. This is currently only available for files with binary content 
#                    in Google Drive.  
# + modifiedByMeTime - The last time the file was modified by the user (RFC 3339 date-time). 
# + modifiedByMe - Whether the file has been modified by this user.
# + shared - Whether the file has been shared. Not populated for items in shared drives.  
# + hasAugmentedPermissions - Whether there are permissions directly on this file. 
#                             This field is only populated for items in shared drives.  
# + description - A short description of the file.  
# + trashingUser - If the file has been explicitly trashed, the user who trashed it. Only populated for items in shared 
#                  drives.  
# + thumbnailLink - A short-lived link to the file's thumbnail, if available. Typically lasts on the order of hours. 
#                   Only populated when the requesting app can access the file's content. 
#                   If the file isn't shared publicly, the URL returned in Files.thumbnailLink must be fetched using 
#                   a credentialed request.  
# + permissionIds - List of permission IDs for users with access to this file.  
# + quotaBytesUsed - The number of storage quota bytes used by the file.  This includes the head revision as well as 
#                    previous revisions with keepForever enabled.  
# + lastModifyingUser - The last user to modify the file.  
# + md5Checksum - The MD5 checksum for the content of the file. This is only applicable to files with binary content
#                 in Google Drive.  
# + fileExtension - The final component of fullFileExtension. This is only available for files with binary content 
#                   in Google Drive.  
# + fullFileExtension - The full file extension extracted from the name field.  May contain multiple concatenated 
#                       extensions, such as "tar.gz".This is only available for files with binary content in Google 
#                       Drive.  
# + webContentLink - A link for downloading the content of the file in a browser. This is only available for files with 
#                    binary content in Google Drive.  
# + shortcutDetails - Shortcut file details.Only populated for shortcut files, which have the mimeType field set to 
#                     application/vnd.google-apps.shortcut  
# + hasThumbnail - Whether this file has a thumbnail. This does not indicate whether the requesting app has access 
#                  to the thumbnail.To check access,look for the presence of the thumbnailLink field.  
# + capabilities - Capabilities the current user has on this file.  Each capability corresponds to a fine-grained 
#                  action that a user may take.  
# + viewedByMeTime - The last time the file was viewed by the user (RFC 3339 date-time).  
# + videoMediaMetadata - Additional metadata about video media. This may not be available immediately upon upload.  
# + thumbnailVersion - The thumbnail version for use in thumbnail cache invalidation.  
# + exportLinks - Links for exporting Docs Editors files to specific formats.  
# + sharingUser - The user who shared the file with the requesting user, if applicable.  
# + properties - A collection of arbitrary key-value pairs which are visible to all apps.  
# + originalFilename - The original filename of the uploaded content if available, or else the original value of the 
#                      name field. This is only available for files with binary content in Google Drive  
public type File record {
    string kind?;
    string id?;  
    string name?;
    string mimeType?;
    string description?;
    boolean starred?;
    boolean trashed?;
    boolean explicitlyTrashed?;
    User trashingUser?;
    string trashedTime?;
    string[] parents?;
    StringKeyValuePairs properties?;
    StringKeyValuePairs appProperties?;
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
    string viewedByMeTime?;
    string createdTime?;
    string modifiedTime?;
    string modifiedByMeTime?;
    string sharedWithMeTime?;
    User sharingUser?;
    User[] owners?;
    string driveId?;
    User lastModifyingUser?;
    boolean shared?;
    boolean ownedByMe?;
    Capabilities capabilities?;
    boolean copyRequiresWriterPermission?;
    boolean writersCanShare?;
    Permissions[] permissions?;
    string[] permissionIds?;
    boolean hasAugmentedPermissions?;
    string folderColorRgb?;
    string originalFilename?;
    string fullFileExtension?;
    string fileExtension?;
    string md5Checksum?;
    int size?; 
    int quotaBytesUsed?;
    string headRevisionId?;
    ContentHints contentHints?;
    ImageMediaMetadata imageMediaMetadata?;
    VideoMediaMetadata videoMediaMetadata?;
    boolean isAppAuthorized?;
    StringKeyValuePairs exportLinks?;
    ShortcutDetails shortcutDetails?;
    ContentRestrictions contentRestrictions?;
};
 
# Record Type to accpet string values  
public type StringKeyValuePairs record {|
    string...;
|};

# Record Type to accept string[] values
public type StringArrayValuePairs record {|
    string[]...;
|};

# Record Type to accept float values  
public type StorageQuota record {|
    float...;
|};

# Restrictions for accessing the content of the file. Only populated if such a restriction exists.
#
# + reason - Reason for why the content of the file is restricted. This is only mutable on requests that also 
#            set readOnly=true.  
# + readOnly - Whether the content of the file is read-only. If a file is read-only, a new revision of the file may not 
#              be added,comments may not be added or modified, and the title of the file may not be modified.  
# + restrictionTime - The time at which the content restriction was set (formatted RFC 3339 timestamp). 
#                     Only populated if readOnly is true.  
# + type - The type of the content restriction. Currently the only possible value is globalContentRestriction.  
# + restrictingUser - The user who set the content restriction. Only populated if readOnly is true.  
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
# + targetId - The ID of the file that this shortcut points to.  
# + targetMimeType - The MIME type of the file that this shortcut points to. The value of this field is a snapshot of 
#                    the target's MIME type, captured when the shortcut is created.  
public type ShortcutDetails record {
    string targetId;
    string targetMimeType;
};

# Additional metadata about video media. This may not be available immediately upon upload.
#
# + width - The width of the video in pixelsn  
# + durationMillis - The duration of the video in milliseconds.  
# + height - The height of the video in pixels.  
public type VideoMediaMetadata record {
    int width;
    int height;
    float durationMillis;
};

# Additional metadata about image media, if available.
#
# + meteringMode - The metering mode used to create the photo. 
# + exposureTime - The length of the exposure, in seconds.
# + whiteBalance - The white balance mode used to create the photo
# + rotation - The number of clockwise 90 degree rotations applied from the image's original orientation. 
# + maxApertureValue - The smallest f-number of the lens at the focal length used to create the photo (APEX value).
# + lens - The lens used to create the photo.
# + exposureBias - The exposure bias of the photo (APEX value)
# + colorSpace - The color space of the photo
# + aperture - The aperture used to create the photo (f-number).
# + flashUsed - Whether a flash was used to create the photo. 
# + subjectDistance - The distance to the subject of the photo, in meters.
# + width - The width of the video in pixels.  
# + cameraModel - The model of the camera used to create the photo. 	
# + location - Geographic location information stored in the image.
# + isoSpeed - The ISO speed used to create the photo.  
# + sensor - The type of sensor used to create the photo
# + time - The date and time the photo was taken (EXIF DateTime). 
# + cameraMake - The make of the camera used to create the photo.
# + exposureMode - The length of the exposure, in seconds.
# + height - The height of the image in pixels.
# + focalLength - The focal length used to create the photo, in millimeters.
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
# + altitude - The altitude stored in the image.  
# + latitude - The latitude stored in the image  
# + longitude - The longitude stored in the image.  
public type Location record {
    float latitude; 
    float longitude; 
    float altitude;
};

# Additional information about the content of the file. These fields are never populated in responses.
#
# + thumbnail - A thumbnail for the file. This will only be used if Google Drive cannot generate a standard thumbnail.  
# + indexableText - Text to be indexed for the file to improve fullText queries. 
#                   This is limited to 128KB in length and may contain HTML elements.  
public type ContentHints record {
    Thumbnail thumbnail;
    string indexableText;
};

# A thumbnail for the file. This will only be used if Google Drive cannot generate a standard thumbnail.
#
# + image - The thumbnail data encoded with URL-safe Base64 (RFC 4648 section 5). 
# + mimeType - The MIME type of the thumbnail.  
public type Thumbnail record {
    byte image;
    string mimeType;
};

# Response from File search 
#
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#fileList".
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

# Optional Query Parameters in GET files.
#
# + acknowledgeAbuse - Whether the user is acknowledging the risk of downloading known malware or other abusive files. 
#                      This is only applicable when alt=media. (Default: false)  
# + includePermissionsForView - Specifies which additional view's permissions to include in the response. 
#                               Only 'published' is supported. 
# + fields - The paths of the fields you want included in the response. 
#            If not specified, the response includes a default set of fields specific to this method. For development 
#            you can use the special value * to return all fields, but you'll achieve greater performance by only 
#            selecting the fields you need  
# + supportsAllDrives - Whether the requesting application supports both My Drives and shared drives. (Default: false)  
public type GetFileOptional record {
    boolean acknowledgeAbuse?;
    string fields?;
    string includePermissionsForView?;
    boolean? supportsAllDrives = true;
};

# Optional Query Parameters in DELETE files
# Permanently deletes a file owned by the user without moving it to the trash. 
#
# + supportsAllDrives - Whether the requesting application supports both My Drives and shared drives. (Default: false)  
public type DeleteFileOptional record {
    boolean? supportsAllDrives = true;
};

# Optional Query Parameters in COPY files
# Creates a copy of a file and applies any requested updates with patch semantics. Folders cannot be copied.
#
# + ocrLanguage - A language hint for OCR processing during image import (ISO 639-1 code).
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
#                               Only 'published' is supported. 
# + fields - The paths of the fields you want included in the response. 
#            If not specified, the response includes a default set of fields 
#            specific to this method. For development you can use the special value * to return all fields, 
#            but you'll achieve greater performance by only selecting the fields you need   
# + supportsAllDrives -   Whether the requesting application supports both My Drives and shared drives.(Default: false)
public type CopyFileOptional record {
    string fields?;
    boolean ignoreDefaultVisibility?;
    string includePermissionsForView?;
    boolean keepRevisionForever?;
    string ocrLanguage?;
    boolean? supportsAllDrives = true;
};

# Optional Query Parameters in Create files
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
#                               Only 'published' is supported. 
# + supportsAllDrives - Whether the requesting application supports both My Drives and shared drives. (Default: false)
public type CreateFileOptional record {
    never uploadType?; 
    boolean ignoreDefaultVisibility?;
    string includePermissionsForView?; 
    boolean keepRevisionForever?; 
    string ocrLanguage?;  
    boolean? supportsAllDrives = true; 
    boolean useContentAsIndexableText?; 
};

# Description
#
# + ocrLanguage - A language hint for OCR processing during image import (ISO 639-1 code).
# + removeParents - A comma-separated list of parent IDs to remove. 
# + keepRevisionForever - Whether to set the 'keepForever' field in the new head revision. 
#                         This is only applicable to files with binary content in Google Drive. 
#                         Only 200 revisions for the file can be kept forever. If the limit is reached,
#                         try deleting pinned revisions. (Default: false)
# + useContentAsIndexableText - Whether to use the uploaded content as indexable text. (Default: false)
# + includePermissionsForView - Specifies which additional view's permissions to include in the response. 
#                               Only 'published' is supported.
# + addParents - A comma-separated list of parent IDs to add.
# + supportsAllDrives -   
public type UpdateFileMetadataOptional record {
   string addParents?; 
   string includePermissionsForView?; 
   boolean keepRevisionForever?; 
   string ocrLanguage?; 
   string removeParents?; 
   boolean? supportsAllDrives = true; 
   boolean useContentAsIndexableText?; 
};

# User Record
#
# + permissionId - The user's ID as visible in Permission resources.  
# + emailAddress - The email address of the user. This may not be present in certain contexts if the user has not made. 
#                   their email address visible to the requester.
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#user". 
# + displayName - A plain text displayable name for this user.
# + me - Whether this user is the requesting user. 
# + photoLink - A link to the user's profile photo, if available.
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
#                        or this item itself if it is not a folder, can be read.
# + canMoveItemOutOfDrive - Whether the current user can move this item outside of this drive by changing its parent. 
#                           Note that a request to change the parent of the item may still fail depending on the new 
#                           parent that is being added.
# + canEdit - Whether the current user can edit this file. 
#             Other factors may limit the type of changes a user can make to a file. 
#             For example, see canChangeCopyRequiresWriterPermission or canModifyContent.
# + canRename - Whether the current user can rename this file.
# + canAddMyDriveParent - Whether the current user can add a parent for the item without removing 
#                         an existing parent in the same request. 
#                         Not populated for shared drive files. 
# + canTrashChildren - Whether the current user can trash children of this folder. 
#                      This is false when the item is not a folder. 
#                      Only populated for items in shared drives. 
# + canAddChildren - Whether the current user can add children to this folder. 
#                    This is always false when the item is not a folder. 
# + canListChildren -  Whether the current user can list the children of this folder. 
#                      This is always false when the item is not a folder.
# + canTrash - Whether the current user can move this file to trash.  
# + canRemoveMyDriveParent - Whether the current user can remove a parent from the item without adding 
#                            another parent in the same request. 
#                            Not populated for shared drive files. 
# + canCopy - Whether the current user can copy this file. For an item in a shared drive, 
#             whether the current user can copy non-folder 
#             descendants of this item, or this item itself if it is not a folder.
# + canDownload - Whether the current user can download this file.
# + canDelete - Whether the current user can delete this file. 
# + canAddFolderFromAnotherDrive - Whether the current user can add a folder from 
#                                  another drive (different shared drive or My Drive) to this folder. 
#                                  This is false when the item is not a folder. Only populated for items 
#                                  in shared drives. 
# + canComment - Whether the current user can comment on this file.  
# + canUntrash - Whether the current user can restore this file from trash.   
# + canMoveChildrenWithinDrive - Whether the current user can move children of this folder within this drive. 
#                                This is false when the item is not a folder. 
#                                Note that a request to move the child may still fail depending on the 
#                                current user's access to the child and to the destination folder
# + canModifyContentRestriction - Whether the current user can modify restrictions on content of this file  
# + canChangeCopyRequiresWriterPermission - Whether the current user can change the copyRequiresWriterPermission 
#                                           restriction of this file.
# + canMoveChildrenOutOfDrive - Whether the current user can move children of this folder outside of the shared drive. 
#                               This is false when the item is not a folder.Only populated for items in shared drives. 
# + canReadDrive - Whether the current user can read the shared drive to which this file belongs. 
#                  Only populated for items in shared drives. 
# + canDeleteChildren - Whether the current user can delete children of this folder. 
#                       This is false when the item is not a folder. 
#                       Only populated for items in shared drives.
# + canMoveItemWithinDrive - Whether the current user can move this item within this drive. 
#                            Note that a request to change the parent of the item may still fail 
#                            depending on the new parent that is being added and the parent that is being removed. 
# + canModifyContent - Whether the current user can modify the content of this file. 
# + canRemoveChildren - Whether the current user can remove children from this folder. This is always false when the 
#                       item is not a folder. For a folder in a shared drive, use canDeleteChildren or canTrashChildren 
#                       instead.   
# + canShare - Whether the current user can modify the sharing settings for this file.
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
# + role - The role granted by this permission.    
# + kind - Identifies what kind of resource this is. Value: the fixed string "drive#permission". 
# + displayName - The "pretty" name of the value of the permission.
# + emailAddress - The email address of the user or group to which this permission refers.  
# + view - Indicates the view for this permission. 
#          Only populated for permissions that belong to a view. published is the only supported value.
# + deleted - Whether the account associated with this permission has been deleted. 
#             This field only pertains to user and group permissions.
# + permissionDetails - Details of whether the permissions on this shared drive item 
#                       are inherited or directly on this item. 
#                       This is an output-only field which is present only for shared drive items.
# + expirationTime - The time at which this permission will expire (RFC 3339 date-time). 
# + domain - The domain to which this permission refers.  
# + id - The ID of this permission. This is a unique identifier for the grantee, 
#        and is published in User resources as permissionId. 
#        IDs should be treated as opaque values.
# + photoLink - A link to the user's profile photo, if available.
# + type - The type of the grantee.  
# + allowFileDiscovery - Whether the permission allows the file to be discovered through search. 
#                        This is only applicable for permissions of type domain or anyone.
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
# + permissionType - The permission type for this user.   
# + role - The primary role for this user.  
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
#                               should be included in results. (Default: false).  
# + q - A query for filtering the file results. See the "Search for files" guide for the supported syntax.
#       https://developers.google.com/drive/api/v3/search-files
# + driveId - ID of the shared drive to search. 
# + spaces - A comma-separated list of spaces to query within the corpus. 
#             Supported values are 'drive', 'appDataFolder' and 'photos'.  
# + corpora - Groupings of files to which the query applies. 
#             Supported groupings are: 'user' (files created by, opened by, or shared directly with the user),
#             'drive' (files in the specified shared drive as indicated by the 'driveId'), 
#             'domain' (files shared to the user's domain), and 'allDrives' 
#             (A combination of 'user' and 'drive' for all drives where the user is a member). 
#             When able, use 'user' or 'drive', instead of 'allDrives', for efficiency.  
# + includePermissionsForView - Specifies which additional view's permissions to include in the response. 
#                               Only 'published' is supported.
# + orderBy - A comma-separated list of sort keys. Valid keys are 'createdTime', 'folder', 
#             'modifiedByMeTime', 'modifiedTime', 'name', 
#            'name_natural', 'quotaBytesUsed', 'recency', 'sharedWithMeTime', 'starred', and 'viewedByMeTime'. 
#             Each key sorts ascending by default, but may be reversed with the 'desc' modifier   
# + pageSize - The maximum number of files to return per page
#              Partial or empty result pages are possible even before the end of the files list has been reached
#              Acceptable values are 1 to 1000, inclusive. (Default: 100).  
# + pageToken - The token for continuing a previous list request on the next page
#               This should be set to the value of 'nextPageToken' from the previous response.
# + fields - The paths of the fields you want included in the response
#            If not specified, the response includes a default set of fields specific to this method.
# + supportsAllDrives -  Whether the requesting application supports both My Drives and shared drives. (Default: false) 
public type ListFilesOptional record {
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
    boolean? supportsAllDrives = true;
};

# Mime types for file operations
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
 
# Optional parameters used in listing changes
#
# + includeItemsFromAllDrives - Whether both My Drive and shared drive items should be included in results.
#                               (Default: false)
# + pageSize - The maximum number of changes to return per page. Acceptable values are 1 to 1000, inclusive. 
#              (Default: 100)
# + driveId - The shared drive from which changes are returned. If specified the change IDs will be reflective of the 
#             shared drive; use the combined drive ID and change ID as an identifier.  
# + restrictToMyDrive - Whether to restrict the results to changes inside the My Drive hierarchy. This omits changes 
#                       to files such as those in the Application Data folder or shared files which have not been added 
#                       to My Drive. (Default: false)
# + includeCorpusRemovals - Whether changes should include the file resource if the file is still accessible by the user 
#                           at the time of the request, even when a file was removed from the list of changes and there 
#                           will be no further change entries for this file. (Default: false) 
# + spaces - A comma-separated list of spaces to query within the user corpus. Supported values are 'drive', 
#            'appDataFolder' and 'photos'. 
# + includePermissionsForView - Specifies which additional view's permissions to include in the response. 
# + includeRemoved - Whether to include changes indicating that items have been removed from the list of changes, 
#                    for example by deletion or loss of access. (Default: true) 
# + fields - The paths of the fields you want included in the response. If not specified, the response includes a 
#            default set of fields specific to this method.  
# + supportsAllDrives - Whether the requesting application supports both My Drives and shared drives. (Default: false)
public type ChangesListOptional record {
    string driveId?;
    string fields?;
    boolean includeCorpusRemovals?;
    boolean includeItemsFromAllDrives?;
    string includePermissionsForView?;
    boolean includeRemoved?;
    int pageSize?;
    boolean restrictToMyDrive?;
    string spaces?;
    boolean? supportsAllDrives = true;
};

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
    File file?;
    string driveId?;
};
