module EntityType exposing (Model(..), candidateRelationshipRadioList, isLLC, llc, orgView, toDataString, toDisplayString)

import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select exposing (Item)
import Html exposing (Html, text)
import Html.Attributes exposing (class, selected, value)


type Model
    = Family
    | Individual
    | SoleProprietorship
    | PartnershipIncludingLLPs
    | Candidate
    | Corporation
    | Committee
    | Union
    | Association
    | LimitedLiabilityCompany
    | PoliticalActionCommittee
    | PoliticalCommittee
    | Other


toDataString : Model -> String
toDataString contributorType =
    case contributorType of
        Family ->
            "Fam"

        Individual ->
            "Ind"

        SoleProprietorship ->
            "Solep"

        PartnershipIncludingLLPs ->
            "Part"

        Corporation ->
            "Corp"

        Committee ->
            "Comm"

        Union ->
            "Union"

        Association ->
            "Assoc"

        LimitedLiabilityCompany ->
            "Llc"

        PoliticalActionCommittee ->
            "Pac"

        PoliticalCommittee ->
            "Plc"

        Other ->
            "Oth"

        Candidate ->
            "Can"


fromString : String -> Maybe Model
fromString str =
    case str of
        "Fam" ->
            Just Family

        "Ind" ->
            Just Individual

        "Solep" ->
            Just SoleProprietorship

        "Part" ->
            Just PartnershipIncludingLLPs

        "Corp" ->
            Just Corporation

        "Comm" ->
            Just Committee

        "Union" ->
            Just Union

        "Assoc" ->
            Just Association

        "Llc" ->
            Just LimitedLiabilityCompany

        "Pac" ->
            Just PoliticalActionCommittee

        "Plc" ->
            Just PoliticalCommittee

        "Can" ->
            Just Candidate

        "Oth" ->
            Just Other

        _ ->
            Nothing


toDisplayString : Model -> String
toDisplayString contributorType =
    case contributorType of
        Family ->
            "Family"

        Individual ->
            "Individual"

        SoleProprietorship ->
            "Sole Proprietorship"

        PartnershipIncludingLLPs ->
            "Partnership including LLPs"

        Corporation ->
            "Corporation"

        Committee ->
            "Committee"

        Candidate ->
            "Candidate"

        Union ->
            "Union"

        Association ->
            "Association"

        LimitedLiabilityCompany ->
            "Professional/Limited Liability Company"

        PoliticalActionCommittee ->
            "Political Action Committee"

        PoliticalCommittee ->
            "Political Committee"

        Other ->
            "Other"


orgView : (Maybe Model -> msg) -> Maybe Model -> Html msg
orgView msg currentValue =
    Select.select
        [ Select.id "contributorType"
        , Select.onChange (fromString >> msg)
        ]
        [ Select.item [ value "" ] [ text "-- Organization Classification --" ]
        , orgSelect SoleProprietorship currentValue
        , orgSelect PartnershipIncludingLLPs currentValue
        , orgSelect Corporation currentValue
        , orgSelect Committee currentValue
        , orgSelect Union currentValue
        , orgSelect Association currentValue
        , orgSelect LimitedLiabilityCompany currentValue
        , orgSelect PoliticalActionCommittee currentValue
        , orgSelect PoliticalCommittee currentValue
        , orgSelect Other currentValue
        ]


orgSelect : Model -> Maybe Model -> Item msg
orgSelect contributorType currentValue =
    Select.item
        [ value <| toDataString contributorType
        , selected <| Just contributorType == currentValue
        ]
        [ text <| toDisplayString contributorType ]


candidateRelationshipRadioList : (Model -> msg) -> Maybe Model -> List (Html msg)
candidateRelationshipRadioList msg currentValue =
    Radio.radioList "candidateRelationship"
        [ Radio.createCustom
            [ Radio.id "can"
            , Radio.inline
            , Radio.onClick (msg Candidate)
            , Radio.checked (currentValue == Just Candidate)
            ]
            "The candidate or spouse of the candidate"
        , Radio.createCustomAdvanced
            [ Radio.id "fam"
            , Radio.inline
            , Radio.onClick (msg Family)
            , Radio.checked (currentValue == Just Family)
            ]
            (Radio.label [] [ text "Family member of the candidate", text "a. Defined as the candidate's child, parent, grandparent, brother, or sister of any such persons " ])
        , Radio.createCustom
            [ Radio.id "ind"
            , Radio.inline
            , Radio.onClick (msg Individual)
            , Radio.checked (currentValue == Just Individual)
            ]
            "N/A"
        ]


isLLC : Model -> Bool
isLLC contributorType =
    contributorType == LimitedLiabilityCompany


llc : Model
llc =
    LimitedLiabilityCompany
