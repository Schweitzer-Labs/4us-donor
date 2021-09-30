module EmploymentStatus exposing (EmploymentStatus(..), toString)


type EmploymentStatus
    = Employed
    | SelfEmployed
    | Retired
    | Unemployed


toString : Maybe EmploymentStatus -> String
toString val =
    case val of
        Just Employed ->
            "Employed"

        Just SelfEmployed ->
            "SelfEmployed"

        Just Retired ->
            "Retired"

        Just Unemployed ->
            "Unemployed"

        Nothing ->
            ""
