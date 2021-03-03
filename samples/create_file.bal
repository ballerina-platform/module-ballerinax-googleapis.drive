import ballerina/log;
import ballerinax/googleapis_drive as drive;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string REFRESH_URL = ?;
configurable string refreshToken = ?;

###################################################################################
# Create file 
###################################################################################
# Creates a new file
# Specify the file Name inside the payload. Else it will be uploaded as Untitled 
# file.
# Specify the mime type also.
# More details : https://developers.google.com/drive/api/v3/mime-types
# ################################################################################
# More details : https://developers.google.com/drive/api/v3/reference/files/create
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

    drive:CreateFileOptional optionals = {
        ignoreDefaultVisibility : false
    };

    drive:File payload = {
        mimeType : "application/vnd.google-apps.file", 
        name : "fileintheroot.txt"
    };

    drive:File|error res = driveClient->createMetaDataFile(optionals, payload);

    //Print file ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:print(id);
    } else {
        log:printError(res.message());
    }
    
}
