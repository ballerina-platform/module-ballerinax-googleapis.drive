import ballerina/log;
import ballerinax/googleapis_drive as drive;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string REFRESH_URL = ?;
configurable string refreshToken = ?;
configurable string fileId = ?;

###################################################################################
# Get files by ID
# ################################################################################
# More details : https://developers.google.com/drive/api/v3/reference/files/get
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

    drive:File | error testGetFile = driveClient->getFileById(fileId);

    //Print file ID
    if(testGetFile is drive:File){
        string id = testGetFile?.id.toString();
        log:print(id);
    } else {
        log:printError(testGetFile.message());
    }

}
