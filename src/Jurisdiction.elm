module Jurisdiction exposing (Model(..), fromString, toString)


type Model
    = MAState
    | NYState


toString : Model -> String
toString val =
    case val of
        MAState ->
            "MA"

        NYState ->
            "NY"


fromString : String -> Model
fromString str =
    case str of
        "MA" ->
            MAState

        "NY" ->
            NYState

        _ ->
            NYState
