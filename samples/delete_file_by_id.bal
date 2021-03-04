import ballerina/log;
import ballerinax/googleapis_drive as drive;

configurable string clientId = ?;
configurable string clientSecret = ?;

configurable string refreshToken = ?;
configurable string fileId = ?;

###################################################################################
# Delete file by ID
###################################################################################
# Permanently deletes a file owned by the user without moving it to the trash. 
# If the file belongs to a shared drive the user must be an organizer on the parent. 
# If the target is a folder, all descendants owned by the user are also deleted.
# ################################################################################
# More details : https://developers.google.com/drive/api/v3/reference/files/delete
# #################################################################################

public function main() {

    drive:Configuration config = {
        clientConfig: {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshUrl: REFRESH_URL,
            refreshToken: refreshToken
        }
    };

    drive:Client driveClient = new (config);

    drive:DeleteFileOptional delete_optional = {
        supportsAllDrives : false
    };

    //Do not supply a request body with this method.
    //If successful, this method returns an empty response body.

    boolean|error res = driveClient->deleteFileById(fileId, delete_optional);

    if(res is boolean){
        log:print("File Deleted");
    } else {
        log:printError(res.message());
    }

}
