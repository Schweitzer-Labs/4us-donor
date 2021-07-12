module Settings exposing (Model, get, init, toJustOrgOrNothing)

import OrgOrInd


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


toJustOrgOrNothing : Model -> Maybe OrgOrInd.Model
toJustOrgOrNothing model =
    if not model.complianceEnabled then
        Just OrgOrInd.Ind

    else
        Nothing
