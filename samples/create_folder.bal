import ballerina/log;
import ballerina/os;
import ballerinax/googleapis_drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

###################################################################################
# Create folder 
###################################################################################
# Creates a new folder
# Specify the file Name inside the payload. Else it will be uploaded as Untitled 
# folder.
# Specify the mime type as application/vnd.google-apps.folder
# More details : https://developers.google.com/drive/api/v3/mime-types
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

    string name = "folderInTheRoot";
    
    drive:File|error res = driveClient->createFolder(name);
    // drive:File|error response = driveClient->createFolder(folderName, parentFolderId);

    //Print folder ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:print(id);
    } else {
        log:printError(res.message());
    }

}
