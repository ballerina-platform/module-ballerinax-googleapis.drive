import ballerina/log;
import ballerina/os;
import ballerinax/googleapis_drive as drive;

configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string refreshUrl = os:getEnv("REFRESH_URL");

##############################
# Search Google forms by name
# ###########################


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

    stream<drive:File>|error res = driveClient->getFormsByName("ballerina");
    // stream<drive:File>|error res = driveClient->getFormsByName("ballerina", 2);
    // stream<drive:File>|error res = driveClient->getFormsByName("ballerina", 2, "createdTime");

    if (res is stream<drive:File>){
        error? e = res.forEach(function (drive:File file) {
            json|error jsonObject = file.cloneWithType(json);
            if (jsonObject is json) {
                log:print(jsonObject.toString());
            }
        });
    }

}
