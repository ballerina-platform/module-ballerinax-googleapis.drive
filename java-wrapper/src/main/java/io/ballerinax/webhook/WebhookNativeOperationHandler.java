package io.ballerinax.webhook;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Future;
import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.async.Callback;
import io.ballerina.runtime.api.async.StrandMetadata;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.MethodType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import java.util.ArrayList;
import java.util.concurrent.CountDownLatch;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

public class WebhookNativeOperationHandler {
    public static Object callOnFileCreateMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFileCreateMethod", "onFileCreate");
    }
    public static Object callOnFileCreateOnSpecificFolderMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFileCreateOnSpecificFolderMethod", "onFileCreateOnSpecificFolder");
    }
    public static Object callOnFileDeleteMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFileDeleteMethod", "onFileDelete");
    }
    public static Object callOnFileDeleteOnSpecificFolderMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFileDeleteOnSpecificFolderMethod", "onFileDeleteOnSpecificFolder");
    }
    public static Object callOnFileUpdateMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFileUpdateMethod", "onFileUpdate");
    }
    public static Object callOnFileUpdateOnSpecificFolderMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFileUpdateOnSpecificFolderMethod", "onFileUpdateOnSpecificFolder");
    }
    public static Object callOnFolderCreateMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFolderCreateMethod", "onFolderCreate");
    }
    public static Object callOnFolderCreateOnSpecificFolderMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFolderCreateOnSpecificFolderMethod", "onFolderCreateOnSpecificFolder");
    }
    public static Object callOnFolderDeleteMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFolderDeleteMethod", "onFolderDelete");
    }
    public static Object callOnFolderDeleteOnSpecificFolderMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFolderDeleteOnSpecificFolderMethod", "onFolderDeleteOnSpecificFolder");
    }
    public static Object callOnFolderUpdateMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFolderUpdateMethod", "onFolderUpdate");
    }
    public static Object callOnFolderUpdateOnSpecificFolderMethod(Environment env, BObject bWebhookService, BMap<BString, Object> message) {
        return invokeRemoteFunction(env, bWebhookService, message, "callOnFolderUpdateOnSpecificFolderMethod", "onFolderUpdateOnSpecificFolder");
    }

    public static BArray getServiceMethodNames(BObject bSubscriberService) {
        ArrayList<BString> methodNamesList = new ArrayList<>();
        for (MethodType method : bSubscriberService.getType().getMethods()) {
            methodNamesList.add(StringUtils.fromString(method.getName()));
        }
        return ValueCreator.createArrayValue(methodNamesList.toArray(BString[]::new));
    }

    private static Object invokeRemoteFunction(Environment env, BObject bWebhookService, BMap<BString, Object> message,
                                               String parentFunctionName, String remoteFunctionName) {
        Future balFuture = env.markAsync();
        Module module = ModuleUtils.getModule();
        StrandMetadata metadata = new StrandMetadata(module.getOrg(), module.getName(), module.getVersion(),
                parentFunctionName);
        Object[] args = new Object[]{message, true};
        env.getRuntime().invokeMethodAsync(bWebhookService, remoteFunctionName, null, metadata, new Callback() {
            @Override
            public void notifySuccess(Object result) {
                balFuture.complete(result);
            }

            @Override
            public void notifyFailure(BError bError) {
                BString errorMessage = fromString("service method invocation failed: " + bError.getErrorMessage());
                BError invocationError = ErrorCreator.createError(errorMessage, bError);
                balFuture.complete(invocationError);
            }
        }, args);
        return null;
    }
}