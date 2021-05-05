## Compatibility

| Ballerina Language Version | Gdrive API Version|  
|:--------------------------:|:-----------------:|
| Swan Lake Alpha 5          |   v3              |

### Prerequisites

* To use Gdrive endpoint, you need to provide the following:
    * Client Id
    * Client Secret
    * Refresh Token
    or you can provide
    * Access Token

* Go through the following steps to obtain client id, client secret, refresh token and access token for Gdrive API.
    *   Go to [Google API Console](https://console.developers.google.com) to create a project and an app for the project to connect with Gdrive API.
    
    *   Configure the OAuth consent screen under **Credentials** and give a product name to shown to users.
    
    *   Create OAuth Client ID credentials by selecting an application type and giving a name and a redirect URI.

    * Give the redirect URI as (https://developers.google.com/oauthplayground), if you are using [OAuth 2.0 Playground](https://developers.google.com/oauthplayground) to
    receive the authorization code and obtain access token and refresh token.*

    *   Visit [OAuth 2.0 Playground](https://developers.google.com/oauthplayground) and select the required Gdrive API scopes.

    *   Give previously obtained client id and client secret and obtain the refresh token and access token.

    
### Working with Gdrive Connector.

In order to use the Gdrive connector, first you need to create a Gdrive endpoint by passing above mentioned parameters.

Open `test.bal` file to find the way of creating Gdrive endpoint.

### Running Gdrive tests
In order to run the tests, the user will need to have a Gdrive account and create a configuration file named `Config.toml` in the project's root directory with the obtained tokens and other parameters.

#### Config.toml
```ballerina

[ballerinax.googleapis.drive]

refreshToken = "enter your refresh token here"
clientId = "enter your client id here"
clientSecret = "enter your client secret here"
```

Assign the values for the clientId, clientSecret and refreshToken inside constructed endpoint in 
test.bal

```ballerina

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = drive:REFRESH_URL;

Gdrive:GdriveConfiguration GdriveConfig = {
    oauthClientConfig: {
        refreshUrl: refreshUrl,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
};

Client GdriveClient = new(GdriveConfig);
```
There is support for providing configuration using access token also.

```
Access token support
Configuration config = {
    clientConfig: {
        token: os:getEnv("ACCESS_TOKEN")
    }
};

```

Assign values for other necessary parameters to perform api operations in test.bal as follows.
```ballerina
configurable string fileName = ?;
configurable string folderName = ?;
```
Run tests :

```
bal test
```