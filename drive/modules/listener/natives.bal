import ballerina/jballerina.java;
import ballerinax/googleapis_drive as drive;

isolated function callOnFileCreateMethod(SimpleHttpService httpService, drive:Change changeInfo)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderCreateMethod(SimpleHttpService httpService, drive:Change changeInfo)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFileUpdateMethod(SimpleHttpService httpService, drive:Change changeInfo)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderUpdateMethod(SimpleHttpService httpService, drive:Change changeInfo)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnDeleteMethod(SimpleHttpService httpService, drive:Change changeInfo)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnTrashMethod(SimpleHttpService httpService, drive:Change changeInfo)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

# Invoke native method to retrive implemented method names in the subscriber service
#
# + httpService - current subscriber-service
# + return - {@code string[]} containing the method-names in current implementation
isolated function getServiceMethodNames(SimpleHttpService httpService) returns string[] = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;


