module Main exposing (Model, Msg(..), frameContainer, init, main, update, view)

import AmountSelector
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Browser exposing (Document)
import Browser.Dom as Dom
import ContributorType exposing (ContributorType)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http exposing (Error(..), Expect, emptyBody, expectString, expectStringResponse, jsonBody, post)
import Http.Detailed
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode exposing (encode)
import OrgOrInd as OrgOrInd exposing (OrgOrInd(..))
import State
import SubmitButton exposing (submitButton)
import Task
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
    , memberOwnership : String
    , loading : Bool
    , emailAddress : String
    , phoneNumber : String
    , firstName : String
    , lastName : String
    , address1 : String
    , address2 : String
    , city : String
    , state : String
    , postalCode : String
    , employer : String
    , entityName : String
    , maybeOrgOrInd : Maybe OrgOrInd
    , maybeContributorType : Maybe ContributorType
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    , amount : String
    , errors : List String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { committeeId = "fa5bbc12-0d6f-4302-9b2c-5ca0f14fe28b"
      , donationAmountDisplayState = Open
      , donorInfoDisplayState = Hidden
      , paymentDetailsDisplayState = Hidden
      , amountValidated = False
      , donorInfoValidated = False
      , paymentDetailsValidated = False
      , memberOwnership = ""
      , loading = False
      , emailAddress = ""
      , phoneNumber = ""
      , firstName = ""
      , lastName = ""
      , address1 = ""
      , address2 = ""
      , city = ""
      , state = ""
      , postalCode = ""
      , employer = ""
      , entityName = ""
      , maybeContributorType = Nothing
      , maybeOrgOrInd = Nothing
      , cardNumber = ""
      , expirationMonth = ""
      , expirationYear = ""
      , cvv = ""
      , amount = ""
      , errors = []
      }
    , Cmd.none
    )


type DisplayState
    = Hidden
    | Open
    | Closed


view : Model -> Html Msg
view model =
    div
        []
        [ donationAmountView model
        , provideDonorInfoView model
        , providePaymentDetailsView model
        ]


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
                    [ Row.attrs [ class "z-100" ] ]
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
                    [ Row.attrs [ class "slide-in z-1" ] ]
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
        [ ul [] <| List.map (\error -> li [ class "text-danger list-unstyled" ] [ text error ]) errors
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
        (AmountSelector.view AmountUpdated model.amount SubmitAmount)
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
                    orgRows model ++ piiRows model ++ [ employerRow model ] ++ [ submitDonorButtonRow ]

                Just Ind ->
                    piiRows model ++ [ employerRow model ] ++ familyRow model ++ [ submitDonorButtonRow ]

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
    frameContainer
        model.paymentDetailsDisplayState
        (text "Payment Details")
        model.errors
        (Grid.containerFluid
            []
            (paymentDetailsRows model)
        )
        OpenPaymentDetails


type Msg
    = AmountUpdated String
    | ChooseOrgOrInd (Maybe OrgOrInd)
    | UpdateEmailAddress String
    | UpdateFirstName String
    | UpdateLastName String
    | UpdateAddress1 String
    | UpdateAddress2 String
    | UpdateCity String
    | UpdateState String
    | UpdatePostalCode String
    | UpdateEmployer String
    | UpdateOrganizationName String
    | UpdateOrganizationClassification (Maybe ContributorType)
    | UpdateMemberOwnership String
    | UpdateFamilyOrIndividual ContributorType
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
    | GotAPIResponseContribute (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | NoOp


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
            { model | donationAmountDisplayState = Open, donorInfoDisplayState = Closed, paymentDetailsDisplayState = paymentDetailsToggled, errors = [] }

        DonorInfo ->
            { model | donorInfoDisplayState = Open, donationAmountDisplayState = Closed, paymentDetailsDisplayState = paymentDetailsToggled, errors = [] }

        PaymentDetails ->
            { model | paymentDetailsDisplayState = Open, donationAmountDisplayState = Closed, donorInfoDisplayState = Closed, errors = [] }


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
            ( { model | maybeOrgOrInd = maybeOrgOrInd, maybeContributorType = Nothing, errors = [] }, Cmd.none )

        UpdateOrganizationName entityName ->
            ( { model | entityName = entityName }, Cmd.none )

        UpdateOrganizationClassification maybeContributorType ->
            ( { model | maybeContributorType = maybeContributorType }, Cmd.none )

        UpdateMemberOwnership str ->
            ( { model | memberOwnership = str }, Cmd.none )

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

        UpdateEmployer str ->
            ( { model | employer = str }, Cmd.none )

        UpdateCardNumber str ->
            ( { model | cardNumber = str }, Cmd.none )

        UpdateExpirationMonth str ->
            ( { model | expirationMonth = str }, Cmd.none )

        UpdateExpirationYear str ->
            ( { model | expirationYear = str }, Cmd.none )

        UpdateExpirationMonthAndYear str ->
            ( { model | expirationMonth = str, expirationYear = str }, Cmd.none )

        UpdateCVV str ->
            ( { model | cvv = str }, Cmd.none )

        SubmitPaymentInfo ->
            case validate paymentInfoValidator model of
                Err messages ->
                    ( { model | errors = messages }, Cmd.none )

                _ ->
                    ( { model | errors = [], loading = True }, postContribution model )

        GotAPIResponseContribute res ->
            case res of
                Ok ( metadata, str ) ->
                    ( { model | errors = [ str ] }, Cmd.none )

                Err error ->
                    case error of
                        Http.Detailed.BadBody metadata body str ->
                            ( { model | errors = [ "bad body: " ++ body ] }, Cmd.none )

                        Http.Detailed.BadStatus metadata body ->
                            let
                                errorMessageRes =
                                    Decode.decodeString (Decode.field "errorMessage" Decode.string) body

                                errorMessage =
                                    Result.withDefault "Oops! Something went wrong" errorMessageRes
                            in
                            ( { model | errors = [ errorMessage ] }, Cmd.none )

                        _ ->
                            ( { model | errors = [ "Oops! Something went wrong" ] }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \n -> Sub.none
        , update = update
        , view = view
        }


submitDonorButtonRow : Html Msg
submitDonorButtonRow =
    Grid.row
        [ Row.attrs [ Spacing.mt5 ] ]
        [ Grid.col
            []
            [ submitButton SubmitDonorInfo "Continue" False True ]
        ]


isLLCDonor : Model -> Bool
isLLCDonor model =
    Maybe.withDefault False (Maybe.map ContributorType.isLLC model.maybeContributorType)


memberOwnershipRow : String -> Html Msg
memberOwnershipRow val =
    Grid.row
        []
        [ Grid.col
            [ Col.xs6, Col.attrs [ Spacing.mt3 ] ]
            [ Input.number [ Input.onInput UpdateMemberOwnership, Input.value val, Input.placeholder "Percent Ownership" ]
            ]
        ]


orgRows : Model -> List (Html Msg)
orgRows model =
    let
        llcRow =
            if isLLCDonor model then
                [ memberOwnershipRow model.memberOwnership ]

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
            [ inputText UpdateEmailAddress "Email Address" model.emailAddress ]
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
            [ text "Are you a family member of the candidate that will receive this contribution?" ]
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
            [ OrgOrInd.view ChooseOrgOrInd model.maybeOrgOrInd ]
        ]
    ]


employerRow : Model -> Html Msg
employerRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateEmployer "Employer" model.employer ]
        ]


paymentDetailsRows : Model -> List (Html Msg)
paymentDetailsRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            [ Col.sm6, Col.attrs [ Spacing.p2 ] ]
            [ inputText UpdateCardNumber "Card Number" model.cardNumber ]
        , Grid.col
            [ Col.attrs [ Spacing.p2 ] ]
            [ inputNumber UpdateExpirationMonth "MM" model.expirationMonth ]
        , Grid.col
            [ Col.attrs [ Spacing.p2 ] ]
            [ inputNumber UpdateExpirationYear "YYYY" model.expirationYear ]
        , Grid.col
            [ Col.attrs [ Spacing.p2 ] ]
            [ inputText UpdateCVV "CVV" model.cvv ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt5 ] ]
        [ Grid.col
            []
            [ submitButton SubmitPaymentInfo "Donate!" False True ]
        ]
    ]


inputNumber : (String -> Msg) -> String -> String -> Html Msg
inputNumber msg placeholder val =
    Input.text
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputMonth : (String -> Msg) -> String -> String -> Html Msg
inputMonth msg placeholder val =
    Input.month
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputText : (String -> Msg) -> String -> String -> Html Msg
inputText msg placeholder val =
    Input.text
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


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
                [ memberOwnershipValidator ]

            else
                []
    in
    Validate.firstError ([ organizationValidator, piiValidator ] ++ extra)


memberOwnershipValidator : Validator String Model
memberOwnershipValidator =
    ifBlank .memberOwnership "Please specify your percent ownership."


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
        , ( "creditCardNumber", Encode.string model.cardNumber )
        , ( "expirationMonth", Encode.int <| numberStringToInt model.expirationMonth )
        , ( "expirationYear", Encode.int <| numberStringToInt model.expirationYear )
        , ( "paymentMethod", Encode.string "credit" )
        , ( "contributorType", Encode.string <| ContributorType.toDataString <| Maybe.withDefault ContributorType.llc model.maybeContributorType )
        , ( "companyName", Encode.string model.entityName )
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
