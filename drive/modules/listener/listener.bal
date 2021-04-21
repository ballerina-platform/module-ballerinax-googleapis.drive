import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
// import ballerina/task;
// import ballerina/time;

# Listener Configuration. 
#
# + port - Port for the listener.  
# + specificFolderOrFileId - Folder or file Id.  
# + callbackURL - Callback URL registered.   
# + clientConfiguration - Drive client connecter configuration.
public type ListenerConfiguration record {
    int port;
    string callbackURL;
    drive:Configuration clientConfiguration;
    string? specificFolderOrFileId = ();
};

# Drive event listener   
@display {label: "Google Drive Listener"}
public class Listener {
    private string currentToken;
    private string channelUuid;
    private string watchResourceId;
    private http:Client clientEP;
    private string specificFolderOrFileId;
    private drive:Client driveClient;
    private drive:WatchResponse watchResponse;
    private boolean isWatchOnSpecificResource = false;
    private boolean isAFolder = true;
    private ListenerConfiguration config;
    private http:Listener httpListener;
    private HttpService httpService;

    public isolated function init(ListenerConfiguration config) returns @tainted error? {
        self.httpListener = check new (config.port);
        self.driveClient = check new (config.clientConfiguration);
        self.config = config;
         if (self.config.specificFolderOrFileId is string) {
            self.isAFolder = check checkMimeType(self.driveClient, self.config.specificFolderOrFileId.toString());
        }
        if (self.config.specificFolderOrFileId is string && self.isAFolder == true) {
            check validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = check startWatch(self.config.callbackURL, self.driveClient, self.specificFolderOrFileId.
            toString());
            self.isWatchOnSpecificResource = true;
        } else if (self.config.specificFolderOrFileId is string && self.isAFolder == false) {
            check validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = check startWatch(self.config.callbackURL, self.driveClient, self.specificFolderOrFileId);
            self.isWatchOnSpecificResource = true;
        } else {
            self.specificFolderOrFileId = EMPTY_STRING;
            self.watchResponse = check startWatch(self.config.callbackURL, self.driveClient);
        }
        self.channelUuid = self.watchResponse?.id.toString();
        self.currentToken = self.watchResponse?.startPageToken.toString();
        self.watchResourceId = self.watchResponse?.resourceId.toString();
        // self.expiration = self.watchResponse?.expiration.toString();
        log:printInfo("Watch channel started in Google, id : " + self.channelUuid);
        // schedular start
        // expiration time >>>    
    }

    public isolated function attach(SimpleHttpService s, string[]|string? name = ()) returns error? {
        self.httpService = new HttpService(s, self.channelUuid, self.currentToken, self.watchResourceId, self.driveClient, self.isWatchOnSpecificResource, self.isAFolder, self.specificFolderOrFileId);
        check self.httpListener.attach(self.httpService, name);

        // time:Utc currentUtc = time:utcNow();
        // time:Civil time = time:utcToCivil(currentUtc);
        // task:JobId result = check task:scheduleOneTimeJob(new Job(self.config, self.driveClient, self, self.httpService, 
        // self.currentFileStatus), time);
    }

    public isolated function detach(service object {} s) returns error? {
        check self.httpListener.detach(s);
    }

    public isolated function 'start() returns error? {
        check self.httpListener.'start();
    }

    public isolated function gracefulStop() returns error? {
        return self.httpListener.gracefulStop();
    }

    public isolated function immediateStop() returns error? {
        return self.httpListener.immediateStop();
    }


//     public isolated function registerWebhook() returns drive:WatchResponse|error {
//         if (self.config.specificGsheetId is string) {
//             self.isValidGsheet = checkpanic checkMimeType(self.driveClient, self.config.specificGsheetId.toString());
//         }
//         if (self.isValidGsheet == true) {
//             self.specificGsheetId = self.config.specificGsheetId.toString();
//             self.watchResponse = checkpanic startWatchChannel(self.config.callbackURL, self.driveClient, 
//                 self.config.expiration, self.specificGsheetId);
//             checkpanic getCurrentStatusOfFile(self.driveClient, self.currentFileStatus, self.specificGsheetId);
//         } 
//         self.channelUuid = self.watchResponse?.id.toString();
//         self.watchResourceId = self.watchResponse?.resourceId.toString();
//         self.currentToken = self.watchResponse?.startPageToken.toString();
//         self.expiration = self.watchResponse?.expiration;
//         log:printInfo("Subscribed to watch channel ID : " + self.channelUuid);
//         log:printInfo("Start page token for the current state of the account: " + self.currentToken);
//         return self.watchResponse;
//         // else {
//         //     self.specificGsheetId = EMPTY_STRING;
//         //     self.watchResponse = checkpanic startWatchChannel(self.config.callbackURL, self.driveClient,
//         //         self.config.expiration);
//         //     checkpanic getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus);
//         //     return self.watchResponse;
//         // }
//     }

//     public isolated function scheduleNextWebhookRenewal(drive:WatchResponse watchResponse) returns error? {
//         time:Utc currentUtc = time:utcNow();
//         time:Utc newTime = time:utcAddSeconds(currentUtc, <decimal>self.config.expiration);
//         time:Civil time = time:utcToCivil(newTime);

//         task:JobId result = checkpanic task:scheduleOneTimeJob(new Job(self.config, self.driveClient, self, 
//             self.httpService, self.currentFileStatus), time);
//     }
}

