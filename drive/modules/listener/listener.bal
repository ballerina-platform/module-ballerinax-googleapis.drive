import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;

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
    private json[] currentFileStatus = [];
    private string specificFolderOrFileId;
    private drive:Client driveClient;
    private drive:WatchResponse watchResponse;
    private boolean isWatchOnSpecificResource = false;
    private boolean isAFolder = true;
    private ListenerConfiguration config;
    private http:Listener httpListener;
    private HttpService httpService;

    public function init(ListenerConfiguration config) returns @tainted error? {
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
            check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus, 
            self.specificFolderOrFileId.toString());
            self.isWatchOnSpecificResource = true;
        } else if (self.config.specificFolderOrFileId is string && self.isAFolder == false) {
            check validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = check startWatch(self.config.callbackURL, self.driveClient, self.specificFolderOrFileId);
            self.isWatchOnSpecificResource = true;
            check getCurrentStatusOfFile(self.driveClient, self.currentFileStatus, self.specificFolderOrFileId);
        } else {
            self.specificFolderOrFileId = EMPTY_STRING;
            self.watchResponse = check startWatch(self.config.callbackURL, self.driveClient);
            check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus);
        }
        self.channelUuid = self.watchResponse?.id.toString();
        self.currentToken = self.watchResponse?.startPageToken.toString();
        // expiration time
        self.watchResourceId = self.watchResponse?.resourceId.toString();
        log:printInfo("Watch channel started in Google, id : " + self.channelUuid);
        // schedular start
        // expiration time >>>    
    }

    public isolated function attach(SimpleHttpService s, string[]|string? name = ()) returns error? {
        self.httpService = new HttpService(s, self.currentFileStatus, self.channelUuid, self.currentToken, self.watchResourceId, self.driveClient, self.isWatchOnSpecificResource, self.isAFolder, self.specificFolderOrFileId);
        check self.httpListener.attach(self.httpService, name);
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
}

