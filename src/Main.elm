module Main exposing (Model, Msg(..), frameContainer, init, main, update, view)

import AmountSelector
import AppInput exposing (inputEmail, inputNumber, inputText)
import Asset
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Table as Table
import Bootstrap.Utilities.Spacing as Spacing
import Browser exposing (Document)
import Browser.Dom as Dom
import CommitteePage
import ContributorType exposing (ContributorType)
import Copy
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Http exposing (Error(..), Expect, jsonBody, post)
import Http.Detailed
import Json.Decode as Decode
import Json.Encode as Encode exposing (encode)
import Mailto
import OrgOrInd as OrgOrInd exposing (OrgOrInd(..))
import Owners exposing (Owner, Owners)
import SelectRadio
import State
import SubmitButton exposing (submitButton)
import Task
import Url
import Url.Parser exposing ((<?>), parse, top)
import Url.Parser.Query as Query exposing (Parser)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, ifNothing, validate)



-- MODEL


type alias Model =
    { committeeId : String
    , donationAmountDisplayState : DisplayState
    , donorInfoDisplayState : DisplayState
    , paymentDetailsDisplayState : DisplayState
    , amountValidated : Bool
    , donorInfoValidated : Bool
    , paymentDetailsValidated : Bool
    , errors : List String
    , submitMode : Bool
    , submitting : Bool
    , submitted : Bool
    , remaining : Maybe Int
    , emailAddress : String
    , phoneNumber : String
    , firstName : String
    , lastName : String
    , address1 : String
    , address2 : String
    , city : String
    , state : String
    , postalCode : String
    , employmentStatus : String
    , employer : String
    , occupation : String
    , entityName : String
    , maybeOrgOrInd : Maybe OrgOrInd
    , maybeContributorType : Maybe ContributorType
    , attestation : Bool
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    , amount : String
    , owners : Owners
    , ownerName : String
    , ownerOwnership : String
    , ref : String
    }


committeeIdParser =
    top <?> Query.string "committeeId"


refParser =
    top <?> Query.string "refCode"


init : String -> ( Model, Cmd Msg )
init urlString =
    case Url.fromString urlString of
        Just url ->
            let
                committeeId =
                    Maybe.withDefault "" <| Maybe.withDefault (Just "") <| parse committeeIdParser url

                ref =
                    Maybe.withDefault "" <| Maybe.withDefault (Just "") <| parse refParser url
            in
            ( initModel committeeId ref, Cmd.none )

        Nothing ->
            ( initModel "" "", Cmd.none )


initModel : String -> String -> Model
initModel committeeId ref =
    { committeeId = committeeId
    , donationAmountDisplayState = Open
    , donorInfoDisplayState = Hidden
    , paymentDetailsDisplayState = Hidden
    , amountValidated = False
    , donorInfoValidated = False
    , paymentDetailsValidated = False
    , attestation = False
    , errors = []
    , emailAddress = ""
    , phoneNumber = ""
    , firstName = ""
    , lastName = ""
    , address1 = ""
    , address2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , employmentStatus = ""
    , employer = ""
    , occupation = ""
    , entityName = ""
    , maybeContributorType = Nothing
    , maybeOrgOrInd = Nothing
    , cardNumber = ""
    , expirationMonth = ""
    , expirationYear = ""
    , cvv = ""
    , amount = ""
    , submitMode = False
    , submitting = False
    , submitted = False
    , remaining = Nothing
    , owners = []
    , ownerName = ""
    , ownerOwnership = ""
    , ref = ref
    }


type DisplayState
    = Hidden
    | Open
    | Closed


view : Model -> Html Msg
view model =
    CommitteePage.view (stateView model)


stateView : Model -> Html Msg
stateView model =
    if model.submitted then
        div [ class "text-center text-success display-4", Spacing.mt5 ]
            [ h3 [] [ text "Thank you for contributing!" ]
            , logoWingDiv
            ]

    else
        let
            donateButtonOrNot =
                case ( model.submitMode, model.remaining ) of
                    ( True, Just 0 ) ->
                        sendMessageRows model

                    ( True, Just _ ) ->
                        [ div [ Spacing.m4 ] [ donateButton model ] ]

                    _ ->
                        []
        in
        div
            [ class "bg-form", Spacing.pb5 ]
            ([ donationAmountView model
             , provideDonorInfoView model
             , providePaymentDetailsView model
             ]
                ++ donateButtonOrNot
                ++ [ logoDiv ]
            )


logoDiv : Html Msg
logoDiv =
    div [ class "text-center" ] [ img [ Asset.src Asset.usLogo, class "logo-small", Spacing.mt4 ] [] ]


logoWingDiv : Html Msg
logoWingDiv =
    div [ class "text-center" ] [ img [ Asset.src Asset.usLogoWing, class "logo-medium", Spacing.mt4 ] [] ]


frameContainer : DisplayState -> Html Msg -> List String -> Html Msg -> Msg -> Html Msg
frameContainer displayState title errors inputContent openMsg =
    case displayState of
        Closed ->
            Grid.containerFluid [ class "border-bottom", Spacing.pt3, Spacing.pb3 ] <|
                [ Grid.row
                    []
                    [ Grid.col
                        [ Col.xs9 ]
                        [ h4 [ class "font-weight-bold" ] [ title ] ]
                    , Grid.col
                        [ Col.attrs [ class "text-right cursor-pointer hover-underline text-success", onClick openMsg ] ]
                        [ text "Change" ]
                    ]
                ]

        Open ->
            Grid.containerFluid [ class "border-bottom", Spacing.pt3, Spacing.pb3 ] <|
                [ Grid.row
                    [ Row.attrs [] ]
                    [ Grid.col
                        []
                        [ h4 [ class "font-weight-bold" ] [ title ] ]
                    ]
                , Grid.row
                    []
                    [ Grid.col
                        []
                        (errorMessages errors)
                    ]
                , Grid.row
                    [ Row.attrs [] ]
                    [ Grid.col
                        []
                        [ inputContent ]
                    ]
                ]

        Hidden ->
            div [] []


errorMessages : List String -> List (Html Msg)
errorMessages errors =
    if List.length errors == 0 then
        []

    else
        [ Grid.containerFluid
            []
            [ Grid.row
                []
                [ Grid.col
                    []
                  <|
                    List.map (\error -> div [ class "text-danger list-unstyled" ] [ text error ]) errors
                ]
            ]
        ]


titleWithData : String -> String -> Html Msg
titleWithData title data =
    span [] [ text (title ++ ": "), span [ class "text-primary" ] [ text data ] ]


donationAmountView : Model -> Html Msg
donationAmountView model =
    let
        title =
            if String.length model.amount > 0 then
                titleWithData "Donation Amount" ("$" ++ model.amount)

            else
                text "Donation Amount"
    in
    frameContainer
        model.donationAmountDisplayState
        title
        model.errors
        (AmountSelector.view AmountUpdated model.amount SubmitAmount (model.submitMode == False))
        OpenDonationAmount


donorInfoTitle : Model -> Html Msg
donorInfoTitle model =
    case model.maybeOrgOrInd of
        Just Org ->
            if String.length model.entityName > 0 then
                titleWithData "Donor Info" model.entityName

            else
                text "Donor Info"

        Just Ind ->
            let
                fullName =
                    model.firstName ++ " " ++ model.lastName
            in
            if String.length fullName > 0 then
                titleWithData "Donor Info" fullName

            else
                text "Donor Info"

        Nothing ->
            text "Donor Info"


provideDonorInfoView : Model -> Html Msg
provideDonorInfoView model =
    let
        formRows =
            case model.maybeOrgOrInd of
                Just Org ->
                    orgRows model ++ piiRows model ++ [ attestationRow model, submitDonorButtonRow model.attestation ]

                Just Ind ->
                    piiRows model ++ employmentRows model ++ familyRow model ++ [ attestationRow model, submitDonorButtonRow model.attestation ]

                Nothing ->
                    []
    in
    frameContainer
        model.donorInfoDisplayState
        (donorInfoTitle model)
        model.errors
        (Grid.containerFluid
            []
         <|
            orgOrIndRow model
                ++ formRows
        )
        OpenDonorInfo


providePaymentDetailsView : Model -> Html Msg
providePaymentDetailsView model =
    let
        title =
            if model.paymentDetailsValidated then
                titleWithData "Payment Details" "Credit"

            else
                text "Payment Details"
    in
    frameContainer
        model.paymentDetailsDisplayState
        title
        model.errors
        (Grid.containerFluid
            []
            (paymentMethodRows ++ paymentDetailsRows model)
        )
        OpenPaymentDetails


type Msg
    = AmountUpdated String
      -- Donor info
    | ChooseOrgOrInd (Maybe OrgOrInd)
    | UpdateEmailAddress String
    | UpdatePhoneNumber String
    | UpdateFirstName String
    | UpdateLastName String
    | UpdateAddress1 String
    | UpdateAddress2 String
    | UpdateCity String
    | UpdateState String
    | UpdatePostalCode String
    | UpdateEmploymentStatus String
    | UpdateEmployer String
    | UpdateOccupation String
    | UpdateOrganizationName String
    | UpdateOrganizationClassification (Maybe ContributorType)
    | UpdateFamilyOrIndividual ContributorType
    | AddOwner
    | UpdateOwnerName String
    | UpdateOwnerOwnership String
      -- Payment info
    | UpdateCardNumber String
    | UpdateExpirationMonth String
    | UpdateExpirationYear String
    | UpdateExpirationMonthAndYear String
    | UpdateCVV String
    | SubmitAmount
    | SubmitDonorInfo
    | SubmitPaymentInfo
    | OpenDonationAmount
    | OpenDonorInfo
    | OpenPaymentDetails
    | UpdateOwner Owner
    | UpdateAttestation Bool
    | GotAPIResponseContribute (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | NoOp
    | UpdatePaymentMethod String


type FormView
    = DonationAmount
    | DonorInfo
    | PaymentDetails


toggleDisplayState : Model -> FormView -> Model
toggleDisplayState model formView =
    let
        paymentDetailsToggled =
            if model.paymentDetailsDisplayState == Hidden then
                Hidden

            else
                Closed
    in
    case formView of
        DonationAmount ->
            { model | donationAmountDisplayState = Open, donorInfoDisplayState = Closed, paymentDetailsDisplayState = paymentDetailsToggled, submitMode = False, remaining = Nothing, errors = [] }

        DonorInfo ->
            { model | donorInfoDisplayState = Open, donationAmountDisplayState = Closed, paymentDetailsDisplayState = paymentDetailsToggled, submitMode = False, remaining = Nothing, errors = [] }

        PaymentDetails ->
            { model | paymentDetailsDisplayState = Open, donationAmountDisplayState = Closed, donorInfoDisplayState = Closed, submitMode = False, errors = [] }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenDonationAmount ->
            ( toggleDisplayState model DonationAmount, Cmd.none )

        OpenDonorInfo ->
            ( toggleDisplayState model DonorInfo, Cmd.none )

        OpenPaymentDetails ->
            ( toggleDisplayState model PaymentDetails, Cmd.none )

        AmountUpdated amount ->
            ( { model | amount = amount, errors = [] }, Cmd.none )

        SubmitAmount ->
            case validate amountValidator model of
                Err messages ->
                    ( { model | errors = messages }, Cmd.none )

                _ ->
                    ( { model
                        | errors = []
                        , donationAmountDisplayState = Closed
                        , donorInfoDisplayState = Open
                      }
                    , scrollUp
                    )

        SubmitDonorInfo ->
            let
                validator =
                    case model.maybeOrgOrInd of
                        Just Org ->
                            orgInfoValidator model

                        Just Ind ->
                            indInfoValidator

                        -- @ToDo refactor out this pointless case.
                        Nothing ->
                            indInfoValidator
            in
            case validate validator model of
                Err messages ->
                    ( { model | errors = messages }, scrollUp )

                _ ->
                    ( { model
                        | errors = []
                        , donationAmountDisplayState = Closed
                        , donorInfoDisplayState = Closed
                        , paymentDetailsDisplayState = Open
                      }
                    , Cmd.none
                    )

        ChooseOrgOrInd maybeOrgOrInd ->
            ( { model | maybeOrgOrInd = maybeOrgOrInd, maybeContributorType = Nothing, errors = [], submitMode = False }, Cmd.none )

        UpdateOrganizationName entityName ->
            ( { model | entityName = entityName, submitMode = False }, Cmd.none )

        UpdateOrganizationClassification maybeContributorType ->
            ( { model | maybeContributorType = maybeContributorType, submitMode = False }, Cmd.none )

        UpdateOwner newOwner ->
            let
                withoutOwner =
                    List.filter (\{ name } -> name /= newOwner.name) model.owners

                withNewOwner =
                    withoutOwner ++ [ newOwner ]
            in
            ( { model | owners = withNewOwner }, Cmd.none )

        AddOwner ->
            let
                newOwner =
                    Owner model.ownerName model.ownerOwnership
            in
            ( { model | owners = model.owners ++ [ newOwner ], ownerOwnership = "", ownerName = "" }, Cmd.none )

        UpdateOwnerName str ->
            ( { model | ownerName = str }, Cmd.none )

        UpdateOwnerOwnership str ->
            ( { model | ownerOwnership = str }, Cmd.none )

        UpdatePhoneNumber str ->
            ( { model | phoneNumber = str }, Cmd.none )

        UpdateEmailAddress str ->
            ( { model | emailAddress = str }, Cmd.none )

        UpdateFirstName str ->
            ( { model | firstName = str }, Cmd.none )

        UpdateLastName str ->
            ( { model | lastName = str }, Cmd.none )

        UpdateAddress1 str ->
            ( { model | address1 = str }, Cmd.none )

        UpdateAddress2 str ->
            ( { model | address2 = str }, Cmd.none )

        UpdatePostalCode str ->
            ( { model | postalCode = str }, Cmd.none )

        UpdateCity str ->
            ( { model | city = str }, Cmd.none )

        UpdateState str ->
            ( { model | state = str }, Cmd.none )

        UpdateFamilyOrIndividual contributorType ->
            ( { model | maybeContributorType = Just contributorType }, Cmd.none )

        UpdateEmploymentStatus str ->
            ( { model | employmentStatus = str }, Cmd.none )

        UpdateEmployer str ->
            ( { model | employer = str }, Cmd.none )

        UpdateOccupation str ->
            ( { model | occupation = str }, Cmd.none )

        UpdateAttestation bool ->
            ( { model | attestation = bool }, Cmd.none )

        UpdatePaymentMethod str ->
            ( model, Cmd.none )

        UpdateCardNumber str ->
            ( { model | cardNumber = str }, Cmd.none )

        UpdateExpirationMonth str ->
            ( { model | expirationMonth = str }, Cmd.none )

        UpdateExpirationYear str ->
            ( { model | expirationYear = str }, Cmd.none )

        UpdateExpirationMonthAndYear str ->
            ( { model | expirationMonth = str, expirationYear = str }, Cmd.none )

        UpdateCVV str ->
            ( { model | cvv = str, submitMode = False }, Cmd.none )

        SubmitPaymentInfo ->
            case validate paymentInfoValidator model of
                Err messages ->
                    ( { model | errors = messages }, Cmd.none )

                _ ->
                    ( { model | errors = [], submitting = True, paymentDetailsValidated = True }, postContribution model )

        GotAPIResponseContribute res ->
            case res of
                Ok ( metadata, str ) ->
                    ( { model | errors = [], submitted = True }, Cmd.none )

                Err error ->
                    case error of
                        Http.Detailed.BadBody metadata body str ->
                            ( { model | errors = [ Copy.genericError ] }, Cmd.none )

                        Http.Detailed.BadStatus metadata body ->
                            case metadata.statusCode of
                                422 ->
                                    ( { model | errors = [ Copy.paymentProcessingFailure ], submitting = False }, Cmd.none )

                                _ ->
                                    let
                                        remainingRes =
                                            Decode.decodeString (Decode.field "remaining" Decode.int) body
                                    in
                                    case remainingRes of
                                        Err _ ->
                                            ( { model | errors = [ Copy.genericError ], submitting = False }, Cmd.none )

                                        Ok remaining ->
                                            if remaining > 0 then
                                                ( { model
                                                    | errors = [ Copy.currentDonationExceedsLimit remaining ]
                                                    , paymentDetailsDisplayState = Closed
                                                    , donorInfoDisplayState = Closed
                                                    , donationAmountDisplayState = Open
                                                    , submitMode = True
                                                    , submitting = False
                                                    , remaining = Just remaining
                                                  }
                                                , Cmd.none
                                                )

                                            else
                                                ( { model
                                                    | errors = []
                                                    , submitting = False
                                                    , remaining = Just remaining
                                                    , submitMode = True
                                                    , donationAmountDisplayState = Closed
                                                    , donorInfoDisplayState = Closed
                                                    , paymentDetailsDisplayState = Closed
                                                  }
                                                , Cmd.none
                                                )

                        _ ->
                            ( { model | errors = [ Copy.genericError ], submitting = False }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


main : Program String Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \n -> Sub.none
        , update = update
        , view = view
        }


submitDonorButtonRow : Bool -> Html Msg
submitDonorButtonRow attestation =
    Grid.row
        [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            []
            [ submitButton SubmitDonorInfo "Continue" False attestation ]
        ]


donateButton : Model -> Html Msg
donateButton model =
    submitButton SubmitPaymentInfo "Donate!" model.submitting (model.submitting == False)


sendMessageButton : Model -> Html Msg
sendMessageButton model =
    a [ Mailto.toHref Copy.contributionEmailHref, class "btn btn-primary btn-block" ]
        [ text "Send Message" ]


isLLCDonor : Model -> Bool
isLLCDonor model =
    Maybe.withDefault False (Maybe.map ContributorType.isLLC model.maybeContributorType)



-- @Todo Add validation for percentage total
-- @Todo Add ability to edit owners


manageOwnerRows : Model -> List (Html Msg)
manageOwnerRows model =
    let
        tableBody =
            Table.tbody [] <|
                List.map
                    (\owner ->
                        Table.tr []
                            [ Table.td [] [ text owner.name ]
                            , Table.td [] [ text owner.percentOwnership ]
                            ]
                    )
                    model.owners

        tableHead =
            Table.simpleThead
                [ Table.th [] [ text "Name" ]
                , Table.th [] [ text "Percent Ownership" ]
                ]

        capTable =
            if List.length model.owners > 0 then
                [ Table.simpleTable ( tableHead, tableBody ) ]

            else
                []
    in
    [ Grid.row
        [ Row.attrs [ Spacing.mt3, Spacing.mb3 ] ]
        [ Grid.col
            []
            [ text "Please specify the current ownership breakdown of your company."
            ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mb3 ] ]
        [ Grid.col
            []
            [ text "*Total percent ownership must equal 100%"
            ]
        ]
    ]
        ++ capTable
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ inputText UpdateOwnerName "Owner Name" model.ownerName
                    ]
                , Grid.col
                    []
                    [ inputText UpdateOwnerOwnership "Percent Ownership" model.ownerOwnership ]
                ]
           , Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    [ Col.xs6, Col.offsetXs6 ]
                    [ submitButton AddOwner "Add another member" False True ]
                ]
           ]


orgRows : Model -> List (Html Msg)
orgRows model =
    let
        llcRow =
            if isLLCDonor model then
                manageOwnerRows model

            else
                []
    in
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ ContributorType.orgView UpdateOrganizationClassification model.maybeContributorType ]
        ]
    ]
        ++ llcRow
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ Input.text
                        [ Input.onInput UpdateOrganizationName
                        , Input.placeholder "Organization Name"
                        , Input.value model.entityName
                        ]
                    ]
                ]
           ]


piiRows : Model -> List (Html Msg)
piiRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputEmail UpdateEmailAddress "Email Address" model.emailAddress ]
        , Grid.col
            []
            [ inputText UpdatePhoneNumber "Phone Number" model.phoneNumber ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateFirstName "First Name" model.firstName ]
        , Grid.col
            []
            [ inputText UpdateLastName "Last Name" model.lastName ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateAddress1 "Address 1" model.address1
            ]
        , Grid.col
            []
            [ inputText UpdateAddress2 "Address 2" model.address2
            ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateCity "City" model.city ]
        , Grid.col
            []
            [ State.view UpdateState model.state ]
        , Grid.col
            []
            [ inputText UpdatePostalCode "Zip" model.postalCode
            ]
        ]
    ]


familyRow : Model -> List (Html Msg)
familyRow model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ div [] [ text "Are you a family member* of the candidate who will receive this contribution?" ]
            , div [ Spacing.pl3, Spacing.pr3, Spacing.pt1 ] [ text "*Defined as the candidate's child, parent, grandparent, brother, sister, and the spouses of any such persons" ]
            ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
          <|
            ContributorType.familyRadioList UpdateFamilyOrIndividual model.maybeContributorType
        ]
    ]


orgOrIndRow : Model -> List (Html Msg)
orgOrIndRow model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            []
            [ text "Will you be donating as an individual or on behalf of an organization?" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ OrgOrInd.row ChooseOrgOrInd model.maybeOrgOrInd ]
        ]
    ]


employerOccupationRow : Model -> Html Msg
employerOccupationRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateEmployer "Employer Name" model.employer ]
        , Grid.col
            []
            [ inputText UpdateOccupation "Occupation" model.occupation ]
        ]


employmentStatusRows : Model -> List (Html Msg)
employmentStatusRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ text "What is your employment status?" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
          <|
            Radio.radioList "employmentStatus"
                [ SelectRadio.view UpdateEmploymentStatus "employed" "Employed" model.employmentStatus
                , SelectRadio.view UpdateEmploymentStatus "unemployed" "Unemployed" model.employmentStatus
                , SelectRadio.view UpdateEmploymentStatus "retired" "Retired" model.employmentStatus
                , SelectRadio.view UpdateEmploymentStatus "self_employed" "Self Employed" model.employmentStatus
                ]
        ]
    ]


boolToString : Bool -> String
boolToString bool =
    if bool then
        "true"

    else
        "false"


stringToBool : String -> Bool
stringToBool str =
    if str == "true" then
        True

    else
        False


needEmployerName : String -> Bool
needEmployerName status =
    case status of
        "employed" ->
            True

        "self_employed" ->
            True

        _ ->
            False


employmentRows : Model -> List (Html Msg)
employmentRows model =
    let
        employerRowOrEmpty =
            if needEmployerName model.employmentStatus then
                [ employerOccupationRow model ]

            else
                []
    in
    employmentStatusRows model ++ employerRowOrEmpty


paymentDetailsRows : Model -> List (Html Msg)
paymentDetailsRows model =
    let
        donateButtonOrNot =
            if model.submitMode == False then
                [ donateButton model ]

            else
                []
    in
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            [ Col.sm6 ]
            [ inputText UpdateCardNumber "Card Number" model.cardNumber ]
        , Grid.col
            []
            [ inputNumber UpdateExpirationMonth "MM" model.expirationMonth ]
        , Grid.col
            []
            [ inputNumber UpdateExpirationYear "YYYY" model.expirationYear ]
        , Grid.col
            []
            [ inputText UpdateCVV "CVV" model.cvv ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt5 ] ]
        [ Grid.col
            []
            donateButtonOrNot
        ]
    ]


attestationRow : Model -> Html Msg
attestationRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt5 ] ]
        [ Grid.col
            []
            [ Checkbox.checkbox
                [ Checkbox.id "attestation"
                , Checkbox.checked model.attestation
                , Checkbox.onCheck UpdateAttestation
                ]
                Copy.attestation
            ]
        ]


sendMessageRows : Model -> List (Html Msg)
sendMessageRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.m3 ] ]
        [ Grid.col
            []
            [ div [ Spacing.p3, Spacing.pt4, Spacing.pb4, class "text-danger" ] [ text Copy.reachedMaximumContribution ] ]
        ]
    ]



-- Validators


amountValidator : Validator String Model
amountValidator =
    ifBlank .amount "Please choose an amount to donate."


piiValidator : Validator String Model
piiValidator =
    Validate.firstError
        [ ifInvalidEmail .emailAddress (\_ -> "Please enter a valid email address.")
        , ifBlank .firstName "First name is missing."
        , ifBlank .lastName "Last name is missing."
        , ifBlank .address1 "Address 1 is missing."
        , ifBlank .city "City is missing."
        , ifBlank .state "State is missing."
        , ifBlank .postalCode "Postal Code is missing."
        ]


familyValidator : Validator String Model
familyValidator =
    ifNothing .maybeContributorType "Please specify your family status."


organizationValidator : Validator String Model
organizationValidator =
    Validate.firstError
        [ ifNothing .maybeContributorType "Please specify your organization classification."
        , ifBlank .entityName "Please specify your organization name."
        ]


indInfoValidator : Validator String Model
indInfoValidator =
    Validate.firstError [ piiValidator, familyValidator ]


orgInfoValidator : Model -> Validator String Model
orgInfoValidator model =
    let
        extra =
            if isLLCDonor model then
                []

            else
                []
    in
    Validate.firstError ([ organizationValidator, piiValidator ] ++ extra)


paymentInfoValidator : Validator String Model
paymentInfoValidator =
    Validate.all
        [ ifBlank .cardNumber "Please specify your card number."
        , ifBlank .expirationMonth "Please specify the expiration month."
        , ifBlank .expirationYear "Please specify the expiration year."
        ]


scrollUp : Cmd Msg
scrollUp =
    Task.attempt (\_ -> NoOp)
        (Dom.setViewport 0 0
            -- It's not worth showing the user anything special if scrolling fails.
            -- If anything, we'd log this to an error recording service.
            |> Task.onError (\_ -> Task.succeed ())
        )



-- HTTP API


type alias Contribution =
    { committeeId : String
    , firstName : String
    , lastName : String
    , employer : Maybe String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , amount : Float
    , creditCardNumber : String
    , expirationMonth : Float
    , expirationYear : Float
    , refCode : Maybe String
    , paymentMethod : String
    , contributorType : String
    , companyName : Maybe String
    , committeeType : Maybe String
    , cpfId : Maybe String
    , principalOfficerFirstName : Maybe String
    , principalOfficerMiddleName : Maybe String
    , principalOfficerLastName : Maybe String
    }


encodeContribution : Model -> Encode.Value
encodeContribution model =
    Encode.object
        [ ( "committeeId", Encode.string model.committeeId )
        , ( "firstName", Encode.string model.firstName )
        , ( "lastName", Encode.string model.lastName )
        , ( "employer", Encode.string model.employer )
        , ( "addressLine1", Encode.string model.address1 )
        , ( "addressLine2", Encode.string model.address2 )
        , ( "city", Encode.string model.city )
        , ( "state", Encode.string model.state )
        , ( "postalCode", Encode.string model.postalCode )
        , ( "amount", Encode.int <| dollarStringToCents model.amount )
        , ( "creditCardNumber", Encode.string "4242424242424242" )
        , ( "expirationMonth", Encode.int <| numberStringToInt model.expirationMonth )
        , ( "expirationYear", Encode.int <| numberStringToInt model.expirationYear )
        , ( "paymentMethod", Encode.string "credit" )
        , ( "contributorType", Encode.string <| ContributorType.toDataString <| Maybe.withDefault ContributorType.llc model.maybeContributorType )
        , ( "companyName", Encode.string model.entityName )
        , ( "refCode", Encode.string model.ref )
        ]


numberStringToInt : String -> Int
numberStringToInt =
    String.toInt >> Maybe.withDefault 0


dollarStringToCents : String -> Int
dollarStringToCents =
    String.toFloat >> Maybe.withDefault 0 >> (*) 100 >> round


postContribution : Model -> Cmd Msg
postContribution model =
    post
        { url = "http://localhost:5000/contribute"
        , body = jsonBody <| encodeContribution model
        , expect =
            Http.Detailed.expectString GotAPIResponseContribute
        }


paymentMethodRows : List (Html Msg)
paymentMethodRows =
    let
        currentValue =
            "credit"
    in
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
          <|
            Radio.radioList
                ""
                [ SelectRadio.view UpdatePaymentMethod "credit" "Credit/Debit" currentValue
                , SelectRadio.view UpdatePaymentMethod "" "eCheck" currentValue
                , SelectRadio.view UpdatePaymentMethod "" "Crypto" currentValue
                ]
        ]
    ]
