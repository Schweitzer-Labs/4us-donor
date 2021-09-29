module Owners exposing (Owner, Owners, encoder, foldOwnership, toFullName, toHash, validator)

import Json.Encode as Encode
import Validate exposing (Validator, ifBlank, ifFalse, isFloat)


type alias Owner =
    { firstName : String
    , lastName : String
    , address1 : String
    , address2 : String
    , city : String
    , state : String
    , postalCode : String
    , percentOwnership : String
    }


type alias Owners =
    List Owner


toHash : Owner -> String
toHash owner =
    owner.firstName
        ++ "-"
        ++ owner.lastName
        ++ "-"
        ++ owner.address1
        ++ "-"
        ++ owner.city
        ++ "-"
        ++ owner.state
        ++ "-"
        ++ owner.postalCode


toFullName : Owner -> String
toFullName owner =
    owner.firstName ++ " " ++ owner.lastName


validator : Validator String Owner
validator =
    Validate.firstError
        [ ifNotFloat .percentOwnership "Ownership percentage must be a valid a number."
        , ifBlank .firstName "Owner First name is missing."
        , ifBlank .lastName "Owner Last name is missing."
        , ifBlank .address1 "Owner Address 1 is missing."
        , ifBlank .city "Owner City is missing."
        , ifBlank .state "Owner State is missing."
        , ifBlank .postalCode "Owner Postal Code is missing."
        ]


ifNotFloat : (subject -> String) -> error -> Validator error subject
ifNotFloat subjectToString error =
    ifFalse (\subject -> isFloat (subjectToString subject)) error


foldOwnership : Owners -> Float
foldOwnership owners =
    List.foldl (+) 0 <|
        List.map (Maybe.withDefault 0 << String.toFloat << .percentOwnership) owners


encoder : Owner -> Encode.Value
encoder owner =
    Encode.object
        [ ( "firstName", Encode.string owner.firstName )
        , ( "lastName", Encode.string owner.lastName )
        , ( "addressLine1", Encode.string owner.address1 )
        , ( "addressLine2", Encode.string owner.address2 )
        , ( "city", Encode.string owner.city )
        , ( "state", Encode.string owner.state )
        , ( "postalCode", Encode.string owner.postalCode )
        , ( "percentOwnership", Encode.string owner.percentOwnership )
        ]
