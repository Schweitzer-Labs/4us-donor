module ContributorType exposing (ContributorType, familyRadioList, isLLC, llc, orgView, toDataString, toDisplayString)

import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select exposing (Item)
import Html exposing (Html, text)
import Html.Attributes exposing (class, selected, value)


type ContributorType
    = Family
    | Individual
    | SoleProprietorship
    | PartnershipIncludingLLPs
    | Corporation
    | Committee
    | Union
    | Association
    | LimitedLiabilityCompany
    | PoliticalActionCommittee
    | PoliticalCommittee
    | Other


toDataString : ContributorType -> String
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


fromString : String -> Maybe ContributorType
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

        "Oth" ->
            Just Other

        _ ->
            Nothing


toDisplayString : ContributorType -> String
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


orgView : (Maybe ContributorType -> msg) -> Maybe ContributorType -> Html msg
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


orgSelect : ContributorType -> Maybe ContributorType -> Item msg
orgSelect contributorType currentValue =
    Select.item
        [ value <| toDataString contributorType
        , selected <| Just contributorType == currentValue
        ]
        [ text <| toDisplayString contributorType ]


familyRadioList : (ContributorType -> msg) -> Maybe ContributorType -> List (Html msg)
familyRadioList msg currentValue =
    Radio.radioList "familyOfCandidate"
        [ Radio.createCustom
            [ Radio.id "yes"
            , Radio.inline
            , Radio.onClick (msg Family)
            , Radio.checked (currentValue == Just Family)
            ]
            "Yes"
        , Radio.createCustom
            [ Radio.id "no"
            , Radio.inline
            , Radio.onClick (msg Individual)
            , Radio.checked (currentValue == Just Individual)
            ]
            "No"
        ]


isLLC : ContributorType -> Bool
isLLC contributorType =
    contributorType == LimitedLiabilityCompany


llc : ContributorType
llc =
    LimitedLiabilityCompany
