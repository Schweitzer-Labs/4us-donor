module Api.Endpoint exposing (Endpoint(..), connectPlaidAndReturnFinicityConnectUrl, launchCommittee, request, signUpAndSendPlaidLinkToken, unwrap, url)

import Config.Env exposing (env)
import Http
import Url.Builder exposing (QueryParameter, string)


{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { body : Http.Body
    , expect : Http.Expect a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    , withCredentials : Bool
    }
    -> Http.Request a
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = unwrap config.url
        , withCredentials = config.withCredentials
        }



-- TYPES


{-| Get a URL to the 4US API.

This is not publicly exposed, because we want to make sure the only way to get one of these URLs is from this module.

-}
type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str



-- "https://9wp0a5f6ic.execute-api.us-east-1.amazonaws.com/dev"


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    -- NOTE: Url.Builder takes care of percent-encoding special URL characters.
    -- See https://package.elm-lang.org/packages/elm/url/latest/Url#percentEncode
    Url.Builder.crossOrigin env.apiEndpoint
        paths
        queryParams
        |> Endpoint



-- ENDPOINTS


signUpAndSendPlaidLinkToken : Endpoint
signUpAndSendPlaidLinkToken =
    url [ "onboarding/sign-up-and-send-plaid-link-token" ] []


connectPlaidAndReturnFinicityConnectUrl : Endpoint
connectPlaidAndReturnFinicityConnectUrl =
    url [ "onboarding/connect-plaid-and-return-finicity-connect-url" ] []


launchCommittee : Endpoint
launchCommittee =
    url [ "onboarding/onboard" ] []
