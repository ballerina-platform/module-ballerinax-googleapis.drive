import ballerina/log;
import ballerina/os;
import ballerinax/googleapis_drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

string fileId = "<PLACE_YOUR_FILE_ID_HERE>";

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
            refreshUrl: refreshUrl,
            refreshToken: refreshToken
        }
    };

    drive:Client driveClient = new (config);

    drive:CopyFileOptional optionals_copy_file = {"includePermissionsForView" : "published"};

    drive:File payload_copy_file = {
        name : "testfile.pdf" //New name
    };

    drive:File|error res = driveClient->copyFile(sourceFileId);
    // drive:File|error response = driveClient->copyFile(sourceFileId, destinationFolderId);
    // drive:File|error response = driveClient->copyFile(sourceFileId, destinationFolderId, newFileName);

    //Print file ID
    if(res is drive:File){
        string id = res?.id.toString();
        log:print(id);
    } else {
        log:printError(res.message());
    }
    
}
