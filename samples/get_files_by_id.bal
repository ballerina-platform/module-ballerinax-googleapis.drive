import ballerina/log;
import ballerina/os;
import nuwantissera/googleapis_drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

string fileId = "<PLACE_YOUR_FILE_ID_HERE>";

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
            refreshUrl: refreshUrl,
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
