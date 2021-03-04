import ballerina/log;
import ballerinax/googleapis_drive as drive;

configurable string clientId = ?;
configurable string clientSecret = ?;

configurable string refreshToken = ?;

###################################################################################
# Create Metadata file 
###################################################################################
# Creates a new metadata file
# Specify the file Name inside the payload. Else it will be uploaded as Untitled 
# file.
# Specify the mime type also.
# More details : https://developers.google.com/drive/api/v3/mime-types
# ################################################################################

public function main() {

    drive:Configuration config = {
        clientConfig: {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshUrl: REFRESH_URL,
            refreshToken: refreshToken
        }
    };

    drive:CreateFileOptional optionals_create_file = {
        ignoreDefaultVisibility : false
    };

    drive:File payload_create_file = {
        mimeType : "application/vnd.google-apps.document",
        name : "nuwan123"
        //parents : [parentFolder]
    };

    drive:Client driveClient = new (config);

    drive:File|error res = driveClient->createMetaDataFile(optionals_create_file, payload_create_file);

    //Print file ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:print(id);
    } else {
        log:printError(res.message());
    }

}
