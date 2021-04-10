import ballerina/jballerina.java;

isolated function callOnFileCreateMethod(SimpleHttpService httpService, EventInfo fileId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFileCreateOnSpecificFolderMethod(SimpleHttpService httpService, EventInfo fileId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFileDeleteMethod(SimpleHttpService httpService, EventInfo fileId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFileDeleteOnSpecificFolderMethod(SimpleHttpService httpService, EventInfo fileId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFileUpdateMethod(SimpleHttpService httpService, EventInfo fileId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFileUpdateOnSpecificFolderMethod(SimpleHttpService httpService, EventInfo fileId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderCreateMethod(SimpleHttpService httpService, EventInfo folderId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderCreateOnSpecificFolderMethod(SimpleHttpService httpService, EventInfo folderId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderDeleteMethod(SimpleHttpService httpService, EventInfo folderId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderDeleteOnSpecificFolderMethod(SimpleHttpService httpService, EventInfo folderId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderUpdateMethod(SimpleHttpService httpService, EventInfo folderId)
                                returns error? = @java:Method {
    'class: "io.ballerinax.webhook.WebhookNativeOperationHandler"
} external;

isolated function callOnFolderUpdateOnSpecificFolderMethod(SimpleHttpService httpService, EventInfo folderId)
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


