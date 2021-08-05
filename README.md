# Ballerina Google Drive Connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-googleapis.drive.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.drive/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Google Drive](https://developers.google.com/drive/api) allows users to store files on their servers, synchronize files across devices, and share files. Google Drive encompasses Google Docs, Google Sheets, and Google Slides, which are a part of the Google Docs Editors office suite that permits the collaborative editing of documents, spreadsheets, presentations, drawings, forms, and more.

The connector supports file and folder management operations related to creating, deleting, updating and retrieving and to get notification for events occurred in the drive.
For more information about configuration and operations, go to the module.
- [ballerinax/googleapis.drive](drive/Module.md)
- [ballerinax/googleapis.drive.listener](drive/modules/listener/Module.md)

## Building from the source

### Setting up the prerequisites
1. Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).

    > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Ballerina Swan Lake Beta3](https://ballerina.io/). 

### Building the source

Execute the commands below to build from the source.

- To build the package:
    ```shell
    bal build -c
    ```
- To build the package without tests: 
    ```shell
    bal build -c --skip-tests
    ```
    
## Contributing to Ballerina
 
As an open source project, Ballerina welcomes contributions from the community.
 
For more information, see [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).
 
## Code of conduct
 
All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).
 
## Useful links
 
* Discuss code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
 