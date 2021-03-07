import ballerina/log;
import ballerina/os;
import ballerinax/googleapis_drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

###################################################################################
# Create file 
# ################################################################################
# More details : https://developers.google.com/drive/api/v3/reference/files/create
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

    string fileName = "newFileName";
    
    drive:File|error response = driveClient->createFile(fileName);
    // drive:File|error response = driveClient->createFile(fileName, mimeType);
    // drive:File|error response = driveClient->createFile(fileName, mimeType, parentFolderId);

    //Print folder ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:print(id);
    } else {
        log:printError(res.message());
    }

}
