import ballerina/log;
import ballerinax/googleapis_drive as drive;

configurable string clientId = ?;
configurable string clientSecret = ?;

configurable string refreshToken = ?;

###################################################################################
# Get files
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

    drive:ListFilesOptional optional_search = {
        pageSize : 3
    };
    
    stream<drive:File>|error res = driveClient->getFiles(optional_search);
    if (res is stream<drive:File>){
        error? e = res.forEach(function (drive:File file) {
            json|error jsonObject = file.cloneWithType(json);
            if (jsonObject is json) {
                log:print(jsonObject.toString());
            }
        });
    }

}
