import ballerina/log;
import ballerina/task;
import ballerina/time;
import ballerinax/googleapis_drive as drive;

class Job {
    *task:Job;
    private SimpleHttpService s;
    string[]|string? name = ();
    private HttpService httpService;
    private Listener httpListener;
    private drive:Client driveClient;
    private ListenerConfiguration config; 

    private boolean isWatchOnSpecificResource = false;
    private boolean isAFolder = true;

    private drive:WatchResponse watchResponse;
    private string channelUuid = EMPTY_STRING;
    private string specificFolderOrFileId = EMPTY_STRING;
    private string watchResourceId = EMPTY_STRING;
    private string currentToken = EMPTY_STRING;
    private int? expiration = 0;

    public isolated function execute() {
        if (self.config.specificFolderOrFileId is string) {
            self.isAFolder = checkpanic checkMimeType(self.driveClient, self.config.specificFolderOrFileId.toString());
        }
       if (self.config.specificFolderOrFileId is string && self.isAFolder == true) {
            checkpanic validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = checkpanic startWatch(self.config.callbackURL, self.driveClient, self.specificFolderOrFileId.
            toString());
            self.isWatchOnSpecificResource = true;
        } else if (self.config.specificFolderOrFileId is string && self.isAFolder == false) {
            checkpanic validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), self.driveClient);
            self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
            self.watchResponse = checkpanic startWatch(self.config.callbackURL, self.driveClient, self.specificFolderOrFileId);
            self.isWatchOnSpecificResource = true;
        } else {
            self.specificFolderOrFileId = EMPTY_STRING;
            self.watchResponse = checkpanic startWatch(self.config.callbackURL, self.driveClient);
        }
        self.channelUuid = self.watchResponse?.id.toString();
        self.currentToken = self.watchResponse?.startPageToken.toString();
        self.watchResourceId = self.watchResponse?.resourceId.toString();
        log:printInfo("Watch channel started in Google, id : " + self.channelUuid);

        self.httpService.channelUuid = self.channelUuid;
        self.httpService.watchResourceId = self.watchResourceId;
        self.httpService.currentToken = self.currentToken;

        self.httpListener.channelUuid = self.channelUuid;
        self.httpListener.watchResourceId = self.watchResourceId;

        time:Utc currentUtc = time:utcNow();
        time:Utc newTime = time:utcAddSeconds(currentUtc, <decimal>self.config.expiration);
        time:Civil time = time:utcToCivil(newTime);

        task:JobId result = checkpanic task:scheduleOneTimeJob(new Job(self.config, self.driveClient, self.httpListener, 
            self.httpService), time);
    }

    isolated function init(ListenerConfiguration config, drive:Client driveClient, Listener httpListener, 
                           HttpService httpService) {
        self.config = config;
        self.driveClient = driveClient;
        self.httpListener = httpListener;
        self.httpService = httpService;
    }
}