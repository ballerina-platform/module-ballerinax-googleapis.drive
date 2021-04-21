import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerina/task;
import ballerina/time;

# Listener Configuration. 
#
# + port - Port for the listener.  
# + specificFolderOrFileId - Folder or file Id.  
# + callbackURL - Callback URL registered. 
# + expiration - Expiration time of the watch channel in seconds  
# + clientConfiguration - Drive client connecter configuration.
public type ListenerConfiguration record {
    int port;
    string callbackURL;
    drive:Configuration clientConfiguration;
    int? expiration = 3600;
    string? specificFolderOrFileId = ();
};

# Drive event listener   
@display {label: "Google Drive Listener"}
public class Listener {
    private string currentToken = "";
    # Watch Channel ID
    public string channelUuid = "";
    private int expiration;
    # Watch Resource ID
    public string watchResourceId = "";
    private http:Client clientEP;
    private string specificFolderOrFileId = "";
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
    }

    public isolated function attach(SimpleHttpService s, string[]|string? name = ()) returns error? {
        self.httpService = new HttpService(s, self.channelUuid, self.currentToken, self.watchResourceId, self.driveClient, self.isWatchOnSpecificResource, self.isAFolder, self.specificFolderOrFileId);
        check self.httpListener.attach(self.httpService, name);

        time:Utc currentUtc = time:utcNow();
        time:Civil time = time:utcToCivil(currentUtc);
        task:JobId result = check task:scheduleOneTimeJob(new Job(self.config, self.driveClient, self, self.httpService), time);
    }

    public isolated function 'start() returns error? {
        check self.httpListener.'start();
    }

    public isolated function detach(service object {} s) returns error? {
        check stopWatchChannel(self.driveClient, self.channelUuid, self.watchResourceId);
        log:printInfo("Unsubscribed from the watch channel ID : " + self.channelUuid);
        return self.httpListener.detach(s);
    }

    public isolated function gracefulStop() returns error? {
        check stopWatchChannel(self.driveClient, self.channelUuid, self.watchResourceId);
        log:printInfo("Unsubscribed from the watch channel ID : " + self.channelUuid);
        return self.httpListener.gracefulStop();
    }

    public isolated function immediateStop() returns error? {
        check stopWatchChannel(self.driveClient, self.channelUuid, self.watchResourceId);
        log:printInfo("Unsubscribed from the watch channel ID : " + self.channelUuid);
        return self.httpListener.immediateStop();
    }
}

