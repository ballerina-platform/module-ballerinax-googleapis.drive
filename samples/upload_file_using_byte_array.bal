import ballerina/log;
import ballerinax/googleapis_drive as drive;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string REFRESH_URL = ?;
configurable string refreshToken = ?;

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
            refreshUrl: REFRESH_URL,
            refreshToken: refreshToken
        }
    };

    drive:UpdateFileMetadataOptional optionals_ = {
        // addParents : parentFolder //Parent folderID
    };

    drive:File payload_ = {
        name : "test123.jpeg"
    };

    drive:File payload = {
        mimeType : "application/vnd.google-apps.folder",
        name : "folderInTheRoot"
    };
    drive:Client driveClient = new (config);
    
    byte[] byteArray = [116,101,115,116,45,115,116,114,105,110,103];

    // Issue : ballerina: too many arguments.
    drive:File|error res = driveClient->uploadFileUsingByteArray(byteArray, optionals_, payload_);

    //Print file ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:print(id);
    } else {
        log:printError(res.message());
    }
}
