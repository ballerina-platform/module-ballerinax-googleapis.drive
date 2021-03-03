import ballerina/log;
import ballerinax/googleapis_drive as drive;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string REFRESH_URL = ?;
configurable string refreshToken = ?;
configurable string fileId = ?;

###################################################################################
# Copy file by ID
###################################################################################
# Creates a copy of a file and applies any requested updates with patch semantics. 
# **Folders cannot be copied
# ################################################################################
# More details : https://developers.google.com/drive/api/v3/reference/files/copy
# #################################################################################
# 

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

    drive:CopyFileOptional optionals_copy_file = {"includePermissionsForView" : "published"};

    drive:File payload_copy_file = {
        name : "testfile.pdf" //New name
    };

    drive:File|error res = driveClient->copyFile(fileId ,optionals_copy_file ,payload_copy_file );

    //Print file ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:print(id);
    } else {
        log:printError(res.message());
    }
    
}
