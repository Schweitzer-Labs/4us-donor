module Settings exposing (Model, init)


type alias Model =
    { complianceEnabled : Bool }


init : Model
init =
    { complianceEnabled = True }


type alias CommitteeId =
    String


get : CommitteeId -> Model
get committeeId =
    case committeeId of
        "ian-cain" ->
            { complianceEnabled = False }

        _ ->
            init
