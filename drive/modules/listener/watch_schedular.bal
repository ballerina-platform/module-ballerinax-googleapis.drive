// // import ballerina/http;
// import ballerina/log;
// import ballerina/task;
// import ballerina/time;
// import ballerinax/googleapis_drive as drive;

// class Job {

//     *task:Job;
//     private SimpleHttpService s;
//     string[]|string? name = ();
//     private HttpService httpService;
//     private Listener httpListener;
//     private drive:Client driveClient;
//     private ListenerConfiguration config; 

//     private boolean isWatchOnSpecificResource = false;
//     private boolean isAFolder = true;

//     private drive:WatchResponse watchResponse;
//     private string channelUuid = "";
//     private string specificFolderOrFileId = "";
//     private string watchResourceId = "";
//     private string currentToken = "";
//     private int? expiration = 0;

//     private json[] currentFileStatus = [];

//     public function execute() {
//         if (self.config.specificFolderOrFileId is string) {
//             self.isAFolder = check checkMimeType(self.driveClient, self.config.specificFolderOrFileId.toString());
//         }
//        if (self.config.specificFolderOrFileId is string && self.isAFolder == true) {
//             check validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), self.driveClient);
//             self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
//             self.watchResponse = check startWatch(self.config.callbackURL, self.driveClient, self.specificFolderOrFileId.
//             toString());
//             check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus, 
//             self.specificFolderOrFileId.toString());
//             self.isWatchOnSpecificResource = true;
//         } else if (self.config.specificFolderOrFileId is string && self.isAFolder == false) {
//             check validateSpecificFolderExsistence(self.config.specificFolderOrFileId.toString(), self.driveClient);
//             self.specificFolderOrFileId = self.config.specificFolderOrFileId.toString();
//             self.watchResponse = check startWatch(self.config.callbackURL, self.driveClient, self.specificFolderOrFileId);
//             self.isWatchOnSpecificResource = true;
//             check getCurrentStatusOfFile(self.driveClient, self.currentFileStatus, self.specificFolderOrFileId);
//         } else {
//             self.specificFolderOrFileId = EMPTY_STRING;
//             self.watchResponse = check startWatch(self.config.callbackURL, self.driveClient);
//             check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus);
//         }
//         self.channelUuid = self.watchResponse?.id.toString();
//         self.currentToken = self.watchResponse?.startPageToken.toString();
//         self.watchResourceId = self.watchResponse?.resourceId.toString();
//         log:printInfo("Watch channel started in Google, id : " + self.channelUuid);

//         self.httpService.channelUuid = self.channelUuid;
//         self.httpService.watchResourceId = self.watchResourceId;
//         self.httpService.currentToken = self.currentToken;
//         self.httpService.currentFileStatus = self.currentFileStatus;

//         self.httpListener.channelUuid = self.channelUuid;
//         self.httpListener.watchResourceId = self.watchResourceId;

//         time:Utc currentUtc = time:utcNow();
//         time:Utc newTime = time:utcAddSeconds(currentUtc, <decimal>self.config.expiration);
//         time:Civil time = time:utcToCivil(newTime);

//         task:JobId result = checkpanic task:scheduleOneTimeJob(new Job(self.config, self.driveClient, self.httpListener, 
//             self.httpService, self.currentFileStatus), time);
//     }

//     isolated function init(SheetListenerConfiguration config, drive:Client driveClient, Listener httpListener, 
//                            HttpService httpService, json[] currentFileStatus) {
//         self.config = config;
//         self.driveClient = driveClient;
//         self.httpListener = httpListener;
//         self.httpService = httpService;
//     }
// }