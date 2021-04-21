import ballerina/jballerina.java;

isolated function callOnFileCreateMethod(SimpleHttpService httpService, EventInfo fileId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderCreateMethod(SimpleHttpService httpService, EventInfo folderId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFileUpdateMethod(SimpleHttpService httpService, EventInfo fileId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderUpdateMethod(SimpleHttpService httpService, EventInfo folderId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnDeleteMethod(SimpleHttpService httpService, EventInfo fileId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnTrashMethod(SimpleHttpService httpService, EventInfo fileId)
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


