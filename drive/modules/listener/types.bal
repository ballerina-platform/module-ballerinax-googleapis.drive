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

# Record type that handles the available methods in the listener. 
# These values is automatically set from the available methods inside the listener.
#
# + isOnNewFileCreate - Trigger on new file creation.  
# + isOnNewFolderCreate - Trigger on new folder creation.  
# + isOnFileUpdate - Trigger on file update.
# + isOnFolderUpdate - Trigger on folder update.   
# + isOnFileTrash - Trigger on file trash operation (Temporary delete).
# + isOnFolderTrash - Trigger on folder trash operation (Temporary delete). 
# + isOnDelete - Trigger on delete operation (Permenantly delete).  
public type MethodNames record {
    boolean isOnNewFileCreate = false;
    boolean isOnNewFolderCreate = false;
    boolean isOnFileUpdate = false;
    boolean isOnFolderUpdate = false;
    boolean isOnFileTrash = false;
    boolean isOnFolderTrash = false;
    boolean isOnDelete = false;
};
