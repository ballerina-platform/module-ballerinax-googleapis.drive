import ballerina/log;
import ballerina/os;
import ballerinax/googleapis_drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

string fileId = "<PLACE_YOUR_FILE_ID_HERE>";

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
            refreshUrl: refreshUrl,
            refreshToken: refreshToken
        }
    };

    drive:Client driveClient = new (config);

    //Do not supply a request body with this method.
    //If successful, this method returns an empty response body.

    boolean|error res = driveClient->deleteFile(fileId);

    if(res is boolean){
        log:print("File Deleted");
    } else {
        log:printError(res.message());
    }

}
