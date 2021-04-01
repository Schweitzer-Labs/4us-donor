module Main exposing (Model, Msg(..), View(..), chooseAmountView, chooseOrgOrIndView, frameContainer, init, main, provideIndInfoView, provideOrgInfoView, update, view, viewButton)

import AmountSelector
import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import Browser exposing (Document)
import ContributorType exposing (ContributorType)
import Html exposing (..)
import Html.Attributes exposing (class, value)
import OrgOrInd as OrgOrInd exposing (OrgOrInd(..))
import State
import Validate exposing (Validator, ifBlank, ifInvalidEmail, ifNotFloat, ifNothing, validate)



-- MODEL


type alias Model =
    { loading : Bool
    , view : View
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
    ( { loading = False
      , view = ChooseAmountView
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


type View
    = ChooseAmountView
    | ChooseOrgOrIndView
    | ProvideIndInfoView
    | ProvideOrgInfoView
    | ProvidePaymentInfoView
    | SuccessView


view : Model -> Html Msg
view model =
    case model.view of
        ChooseAmountView ->
            chooseAmountView model

        ChooseOrgOrIndView ->
            chooseOrgOrIndView model

        ProvideIndInfoView ->
            provideIndInfoView model

        ProvideOrgInfoView ->
            provideOrgInfoView model

        ProvidePaymentInfoView ->
            providePaymentInfoView model

        SuccessView ->
            text "Success!"


frameContainer : String -> String -> List String -> Html Msg -> Msg -> Maybe String -> Bool -> Bool -> Html Msg
frameContainer amount dialogue errors inputContent submitMsg submitText submitEnabled submitLoading =
    let
        amountText =
            if amount /= "" then
                "$" ++ amount

            else
                ""
    in
    div
        []
        [ h5 [ class "text-right text-success", Spacing.pr3, Spacing.mr3, Spacing.pt3 ] [ text amountText ]
        , div [ Spacing.pr4, Spacing.pl4 ] <|
            [ h4 [ class "font-weight-bold", Spacing.m3 ] [ text dialogue ]
            ]
                ++ errorMessages errors
                ++ [ div [ class "input-container" ] [ inputContent ]
                   , Grid.container [ class "action-container" ]
                        [ Grid.row
                            [ Row.attrs [ Spacing.mt3 ] ]
                            [ Grid.col [ Col.xs7 ] []
                            , Grid.col
                                [ Col.xs5, Col.attrs [ class "float-right" ] ]
                                [ viewButton
                                    submitMsg
                                    (Maybe.withDefault "Continue" submitText)
                                    submitLoading
                                    submitEnabled
                                ]
                            ]
                        ]
                   ]
        ]


errorMessages : List String -> List (Html Msg)
errorMessages errors =
    if List.length errors == 0 then
        []

    else
        [ ul [] <| List.map (\error -> li [ class "text-danger" ] [ text error ]) errors
        ]


chooseAmountView : Model -> Html Msg
chooseAmountView model =
    frameContainer
        model.amount
        "Choose an amount to donate:"
        model.errors
        (AmountSelector.view AmountUpdated model.amount)
        SubmitAmount
        Nothing
        True
        model.loading


chooseOrgOrIndView : Model -> Html Msg
chooseOrgOrIndView model =
    frameContainer
        model.amount
        "Will you be donating as an individual or on behalf of an organization?"
        model.errors
        (OrgOrInd.view ChooseOrgOrInd model.maybeOrgOrInd)
        SubmitOrgOrInd
        Nothing
        True
        model.loading


provideIndInfoView : Model -> Html Msg
provideIndInfoView model =
    frameContainer
        model.amount
        "Please provide the following info:"
        model.errors
        (Grid.containerFluid
            []
         <|
            piiRows model
                ++ [ employerRow model ]
                ++ familyRow model
        )
        SubmitIndInfo
        Nothing
        True
        model.loading


provideOrgInfoView : Model -> Html Msg
provideOrgInfoView model =
    frameContainer
        model.amount
        "Please provide the following info:"
        model.errors
        (Grid.containerFluid
            []
         <|
            orgRows model
                ++ piiRows model
        )
        SubmitOrgInfo
        Nothing
        True
        model.loading


providePaymentInfoView : Model -> Html Msg
providePaymentInfoView model =
    frameContainer
        model.amount
        "Enter your payment details:"
        model.errors
        (Grid.containerFluid
            []
            [ paymentDetailsRow model ]
        )
        SubmitPaymentInfo
        (Just "Donate!")
        True
        model.loading


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
    | UpdateFamilyOrIndividual ContributorType
    | UpdateCardNumber String
    | UpdateExpirationMonth String
    | UpdateExpirationYear String
    | UpdateExpirationMonthAndYear String
    | UpdateCVV String
    | SubmitAmount
    | SubmitOrgOrInd
    | SubmitIndInfo
    | SubmitOrgInfo
    | SubmitPaymentInfo


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AmountUpdated amount ->
            ( { model | amount = amount }, Cmd.none )

        SubmitAmount ->
            case validate amountValidator model of
                Err messages ->
                    ( { model | errors = messages }, Cmd.none )

                _ ->
                    ( { model | errors = [], view = ChooseOrgOrIndView }, Cmd.none )

        ChooseOrgOrInd maybeOrgOrInd ->
            ( { model | maybeOrgOrInd = maybeOrgOrInd }, Cmd.none )

        SubmitOrgOrInd ->
            let
                nextView =
                    case model.maybeOrgOrInd of
                        Just val ->
                            case val of
                                Org ->
                                    ProvideOrgInfoView

                                Ind ->
                                    ProvideIndInfoView

                        Nothing ->
                            ChooseOrgOrIndView
            in
            ( { model | view = nextView }, Cmd.none )

        UpdateOrganizationName entityName ->
            ( { model | entityName = entityName }, Cmd.none )

        UpdateOrganizationClassification maybeContributorType ->
            ( { model | maybeContributorType = maybeContributorType }, Cmd.none )

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

        SubmitIndInfo ->
            case validate indInfoValidator model of
                Err messages ->
                    ( { model | errors = messages }, Cmd.none )

                _ ->
                    ( { model | errors = [], view = ProvidePaymentInfoView }, Cmd.none )

        SubmitOrgInfo ->
            case validate orgInfoValidator model of
                Err messages ->
                    ( { model | errors = messages }, Cmd.none )

                _ ->
                    ( { model | errors = [], view = ProvidePaymentInfoView }, Cmd.none )

        SubmitPaymentInfo ->
            case validate paymentInfoValidator model of
                Err messages ->
                    ( { model | errors = messages }, Cmd.none )

                _ ->
                    ( { model | errors = [], loading = True }, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \n -> Sub.none
        , update = update
        , view = view
        }


orgRows : Model -> List (Html Msg)
orgRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ ContributorType.orgView UpdateOrganizationClassification model.maybeContributorType ]
        ]
    , Grid.row
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


employerRow : Model -> Html Msg
employerRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateEmployer "Employer" model.employer ]
        ]


paymentDetailsRow : Model -> Html Msg
paymentDetailsRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt5 ] ]
        [ Grid.col
            [ Col.xs7, Col.attrs [ Spacing.pr0 ] ]
            [ inputText UpdateCardNumber "Card Number" model.cardNumber ]
        , Grid.col
            [ Col.xs5 ]
            [ inputNumber UpdateExpirationMonthAndYear "MM/YY" model.expirationMonth ]
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


viewButton : Msg -> String -> Bool -> Bool -> Html Msg
viewButton msg str loading enabled =
    Button.button
        [ Button.primary
        , Button.block
        , Button.attrs [ Spacing.mt4 ]
        , Button.onClick msg
        , Button.disabled (enabled == False)
        ]
        [ if loading then
            Spinner.spinner
                [ Spinner.small
                ]
                [ Spinner.srMessage "Loading..."
                ]

          else
            text str
        ]


amountValidator : Validator String Model
amountValidator =
    ifBlank .amount "Please choose an amount to donate."


piiValidator : Validator String Model
piiValidator =
    Validate.all
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
    Validate.all
        [ ifNothing .maybeContributorType "Please specify your organization classification."
        , ifBlank .entityName "Please specify your organization name."
        ]


indInfoValidator : Validator String Model
indInfoValidator =
    Validate.all [ piiValidator, familyValidator ]


orgInfoValidator : Validator String Model
orgInfoValidator =
    Validate.all [ organizationValidator, piiValidator ]


paymentInfoValidator : Validator String Model
paymentInfoValidator =
    Validate.all
        [ ifBlank .cardNumber "Please specify your card number."
        , ifBlank .expirationMonth "Please specify the expiration month."
        , ifBlank .expirationYear "Please specify the expiration year."
        ]
