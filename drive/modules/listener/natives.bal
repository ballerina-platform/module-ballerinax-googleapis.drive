// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

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


