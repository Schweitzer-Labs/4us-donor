module EmploymentStatus exposing (EmploymentStatus(..), toString)


type EmploymentStatus
    = Employed
    | SelfEmployed
    | Retired
    | Unemployed


toString : EmploymentStatus -> String
toString val =
    case val of
        Employed ->
            "Employed"

        SelfEmployed ->
            "SelfEmployed"

        Retired ->
            "Retired"

        Unemployed ->
            "Unemployed"
