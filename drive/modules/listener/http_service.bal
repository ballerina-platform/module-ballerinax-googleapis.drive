import ballerina/log;
import ballerina/http;
import ballerinax/googleapis_drive as drive;

service class HttpService {
    
    private string channelUuid;
    private string currentToken;
    private string watchResourceId;
    private json[] currentFileStatus = [];
    private string specificFolderOrFileId;
    private drive:Client driveClient;
    boolean isWatchOnSpecificResource;
    boolean isAFolder = true;

    // private boolean isFileCreated = false;

    private SimpleHttpService httpService;

    public isolated function init(SimpleHttpService httpService, json[] currentFileStatus, string channelUuid, string currentToken, string watchResourceId, drive:Client driveClient, 
                                    boolean isWatchOnSpecificResource, boolean isAFolder,string specificFolderOrFileId) {
        self.httpService = httpService;
        self.channelUuid = channelUuid;
        self.currentToken = currentToken;
        self.watchResourceId = watchResourceId;
        self.driveClient = driveClient;
        self.isAFolder = isAFolder;
        self.isWatchOnSpecificResource = isWatchOnSpecificResource;
        self.specificFolderOrFileId = specificFolderOrFileId;
        self.currentFileStatus = currentFileStatus;

        // string[] methodNames = getServiceMethodNames(httpService);

        // foreach var methodName in methodNames {
        //     match methodName {
        //         "onFileCreate" => {
        //             self.isFileCreated = true;
        //         }
        //         _ => {
        //             log:printError("Unrecognized method [" + methodName + "] found in the implementation");
        //         }
        //     }
        // }
    }

    resource function post events(http:Caller caller, http:Request request) returns error? {
        if(check request.getHeader(GOOGLE_CHANNEL_ID) != self.channelUuid){
            fail error("Diffrent channel IDs found, Resend the watch request");
        } else {
            drive:ChangesListResponse[] response = check getAllChangeList(self.currentToken, self.driveClient);
            foreach drive:ChangesListResponse item in response {
                self.currentToken = item?.newStartPageToken.toString();
                if (self.isWatchOnSpecificResource && self.isAFolder) {
                    log:printDebug("Folder watch response processing");
                    check mapEventForSpecificResource(<@untainted> self.specificFolderOrFileId, <@untainted> item, 
                    <@untainted> self.driveClient, <@untainted> self.httpService, <@untainted> self.currentFileStatus);
                    check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus, self.specificFolderOrFileId);
                } else if (self.isWatchOnSpecificResource && self.isAFolder == false) {
                    log:printDebug("File watch response processing");
                    check mapFileUpdateEvents(self.specificFolderOrFileId, item, self.driveClient, self.httpService, 
                    self.currentFileStatus);
                    check getCurrentStatusOfFile(self.driveClient, self.currentFileStatus, self.specificFolderOrFileId);
                } else {
                    log:printDebug("Whole drive watch response processing");
                    check mapEvents(item, self.driveClient, self.httpService, self.currentFileStatus);
                    check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus);
                }
            } 
            check caller->respond(http:STATUS_OK);
        }
    }
}



