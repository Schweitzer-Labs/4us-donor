module Api exposing
    ( Token(..)
    , addServerError
    , decodeError
    , decodeErrors
    , delete
    , get
    , post
    , put
    , unwrapToken
    )

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string)



-- CRED


type Token
    = Token String


unwrapToken : Token -> String
unwrapToken (Token str) =
    str


credHeader : Token -> Http.Header
credHeader (Token token) =
    Http.header "authorization" ("Bearer " ++ token)



-- PERSISTENCE
-- SERIALIZATION
-- APPLICATION
-- HTTP


get : Endpoint -> Token -> Decoder a -> Http.Request a
get url token decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader token ]
        , body = Http.emptyBody
        , timeout = Nothing
        , withCredentials = False
        }


put : Endpoint -> Token -> Body -> Decoder a -> Http.Request a
put url token body decoder =
    Endpoint.request
        { method = "PUT"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader token ]
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }


post : Endpoint -> Token -> Body -> Decoder a -> Http.Request a
post url token body decoder =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader token ]
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }


delete : Endpoint -> Token -> Body -> Decoder a -> Http.Request a
delete url token body decoder =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader token ]
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }



--settings : Cred -> Http.Body -> Decoder (Cred -> a) -> Http.Request a
--settings cred body decoder =
--    put Endpoint.user cred body (Decode.field "user" (decoderFromCred decoder))
-- ERRORS


addServerError : List String -> List String
addServerError list =
    "Server error" :: list


{-| Many API endpoints include an "errors" field in their BadStatus responses.
-}
decodeErrors : Http.Error -> List String
decodeErrors error =
    case error of
        Http.BadStatus response ->
            response.body
                |> decodeString (field "errors" errorsDecoder)
                |> Result.withDefault [ "Server error" ]

        err ->
            [ "Server error" ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    Decode.keyValuePairs (Decode.list Decode.string)
        |> Decode.map (List.concatMap fromPair)


fromPair : ( String, List String ) -> List String
fromPair ( field, errors ) =
    List.map (\error -> field ++ " " ++ error) errors


decodeError : Http.Error -> String
decodeError error =
    case error of
        Http.BadStatus response ->
            response.body
                |> decodeString (field "errorMessage" string)
                |> Result.withDefault "Server error"

        err ->
            "Server error"
