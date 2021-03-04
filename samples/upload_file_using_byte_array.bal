import ballerina/log;
import ballerina/os;
import nuwantissera/googleapis_drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

###################################################
# Upload file using Byte Array
# #################################################
# You can set byte array as the source and upload. 
# #################################################

public function main() {

    drive:Configuration config = {
        clientConfig: {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshUrl: refreshUrl,
            refreshToken: refreshToken
        }
    };

    drive:UpdateFileMetadataOptional optionals = {
        // addParents : parentFolder //Parent folderID
    };

    drive:File payload = {
        name : "SAMPLE_FILE"
    };  

    drive:Client driveClient = new (config);
    
    byte[] byteArray = [116,101,115,116,45,115,116,114,105,110,103];

    drive:File|error res = driveClient->uploadFileUsingByteArray(byteArray, optionals, payload);

    //Print file ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:print(id);
    } else {
        log:printError(res.message());
    }
}
