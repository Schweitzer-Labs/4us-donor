port module Main exposing (Model, Msg(..), frameContainer, init, main, update, view)

import AmountSelector
import AppInput exposing (inputEmail, inputNumber, inputSecure, inputText, inputToggleSecure)
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
import Content.IanCain as IanCain
import Content.LuisSepulveda as LuisSepulveda
import Copy
import EmploymentStatus exposing (EmploymentStatus)
import EntityType
import Html exposing (Attribute, Html, div, h3, h4, img, span, text)
import Html.Attributes exposing (attribute, class, href)
import Html.Events exposing (onClick)
import Http exposing (Error(..), Expect, jsonBody, post)
import Http.Detailed
import Json.Decode as Decode exposing (bool, decodeValue)
import Json.Encode as Encode exposing (Value)
import Jurisdiction
import OrgOrInd
import Owners as Owner exposing (Owner, Owners)
import SelectRadio
import Settings
import State
import String.Extra
import SubmitButton exposing (submitButton)
import Task
import Url
import Url.Parser exposing ((</>), (<?>), parse, s, string, top)
import Url.Parser.Query as Query exposing (Parser)
import Validate exposing (Validator, fromErrors, ifBlank, ifEmptyList, ifInvalidEmail, ifNothing, validate)



--- PORTS


port sendNumber : String -> Cmd msg


port isValidNumReceiver : (Value -> msg) -> Sub msg


port sendEmail : String -> Cmd msg


port isValidEmailReceiver : (Value -> msg) -> Sub msg



-- MODEL


type alias Model =
    { endpoint : String
    , committeeId : String
    , donationAmountDisplayState : DisplayState
    , donorInfoDisplayState : DisplayState
    , paymentDetailsDisplayState : DisplayState
    , amountValidated : Bool
    , donorInfoValidated : Bool
    , paymentDetailsValidated : Bool
    , phoneNumberValidated : Bool
    , emailAddressValidated : Bool
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
    , employmentStatus : Maybe EmploymentStatus
    , employer : String
    , occupation : String
    , entityName : String
    , maybeOrgOrInd : Maybe OrgOrInd.Model
    , maybeContributorType : Maybe EntityType.Model
    , attestation : Bool
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    , amount : String
    , owners : Owners
    , ownerFirstName : String
    , ownerLastName : String
    , ownerAddress1 : String
    , ownerAddress2 : String
    , ownerCity : String
    , ownerState : String
    , ownerPostalCode : String
    , ownerOwnership : String
    , ref : String
    , cardNumberIsVisible : Bool
    , settings : Settings.Model
    , jurisdiction : Jurisdiction.Model
    }


committeeIdParser =
    s "committee" </> string


refParser =
    top <?> Query.string "refCode"


amountParser =
    top <?> Query.string "amount"


type alias Config =
    { host : String
    , apiEndpoint : String
    , jurisdiction : String
    }


init : Config -> ( Model, Cmd Msg )
init { host, apiEndpoint, jurisdiction } =
    case Url.fromString host of
        Just url ->
            let
                normalizedUrl =
                    { url | path = "" }

                committeeId =
                    Maybe.withDefault "" <| parse committeeIdParser url

                ref =
                    Maybe.withDefault "" <| Maybe.withDefault (Just "") <| parse refParser normalizedUrl

                amount =
                    Maybe.withDefault "" <| Maybe.withDefault (Just "") <| parse amountParser normalizedUrl

                adminArea =
                    Jurisdiction.fromString jurisdiction
            in
            ( initModel apiEndpoint committeeId ref amount adminArea, Cmd.none )

        Nothing ->
            ( initModel apiEndpoint "" "" "" Jurisdiction.NYState, Cmd.none )


initModel : String -> String -> String -> String -> Jurisdiction.Model -> Model
initModel endpoint committeeId ref amount jurisdiction =
    let
        settings =
            Settings.get committeeId
    in
    { endpoint = endpoint
    , committeeId = committeeId
    , donationAmountDisplayState = Open
    , donorInfoDisplayState = Hidden
    , paymentDetailsDisplayState = Hidden
    , amountValidated = False
    , donorInfoValidated = False
    , paymentDetailsValidated = False
    , phoneNumberValidated = False
    , emailAddressValidated = False
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
    , employer = ""
    , occupation = ""
    , entityName = ""
    , maybeContributorType = Nothing
    , maybeOrgOrInd = Settings.toJustOrgOrNothing settings
    , cardNumber = ""
    , expirationMonth = ""
    , expirationYear = ""
    , cvv = ""
    , amount = amount
    , submitMode = False
    , submitting = False
    , submitted = False
    , remaining = Nothing
    , owners = []
    , ownerOwnership = ""
    , ref = ref
    , cardNumberIsVisible = False
    , employmentStatus = Nothing
    , ownerFirstName = ""
    , ownerLastName = ""
    , ownerAddress1 = ""
    , ownerAddress2 = ""
    , ownerCity = ""
    , ownerState = ""
    , ownerPostalCode = ""
    , settings = Settings.get committeeId
    , jurisdiction = jurisdiction
    }


type DisplayState
    = Hidden
    | Open
    | Closed


view : Model -> Document Msg
view model =
    CommitteePage.view model.committeeId (stateView model)


footerCopy : Model -> List (Html Msg)
footerCopy model =
    case model.committeeId of
        "ian-cain" ->
            IanCain.footerCopy

        --"luis-r-sepulveda" ->
        --    LuisSepulveda.footerCopy

        _ ->
            []


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
                ++ footerCopy model
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
        Just OrgOrInd.Org ->
            if String.length model.entityName > 0 then
                titleWithData "My Info" model.entityName

            else
                text "My Info"

        Just OrgOrInd.Ind ->
            let
                fullName =
                    model.firstName ++ " " ++ model.lastName
            in
            if String.length fullName > 1 then
                titleWithData "My Info" fullName

            else
                text "My Info"

        Nothing ->
            text "My Info"


provideDonorInfoView : Model -> Html Msg
provideDonorInfoView model =
    let
        formRows =
            case model.maybeOrgOrInd of
                Just OrgOrInd.Org ->
                    orgRows model ++ piiRows model ++ attestationRow model ++ [ submitDonorButtonRow model.attestation ]

                Just OrgOrInd.Ind ->
                    piiRows model ++ employmentRows model ++ familyRow model ++ attestationRow model ++ [ submitDonorButtonRow model.attestation ]

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
                titleWithData "Payment Details" "Debit/Credit"

            else
                text "Payment Details"
    in
    frameContainer
        model.paymentDetailsDisplayState
        title
        model.errors
        (Grid.containerFluid
            []
            (paymentDetailsRows model)
        )
        OpenPaymentDetails


type Msg
    = AmountUpdated String
      -- Donor info
    | ChooseOrgOrInd (Maybe OrgOrInd.Model)
    | UpdateEmailAddress String
    | UpdatePhoneNumber String
    | UpdateFirstName String
    | UpdateLastName String
    | UpdateAddress1 String
    | UpdateAddress2 String
    | UpdateCity String
    | UpdateState String
    | UpdatePostalCode String
    | UpdateEmploymentStatus EmploymentStatus
    | UpdateEmployer String
    | UpdateOccupation String
    | UpdateOrganizationName String
    | UpdateOrganizationClassification (Maybe EntityType.Model)
    | UpdateFamilyOrIndividual EntityType.Model
    | AddOwner
    | DeleteOwner Owner
    | UpdateOwnerFirstName String
    | UpdateOwnerLastName String
    | UpdateOwnerAddress1 String
    | UpdateOwnerAddress2 String
    | UpdateOwnerCity String
    | UpdateOwnerState String
    | UpdateOwnerPostalCode String
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
    | ToggleCardNumberVisibility Bool
    | GotPhoneValidationRes Decode.Value
    | GotEmailValidationRes Decode.Value


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
                        Just OrgOrInd.Org ->
                            orgInfoValidator model

                        Just OrgOrInd.Ind ->
                            case model.employmentStatus of
                                Just EmploymentStatus.Employed ->
                                    indInfoAndEmployer

                                Just EmploymentStatus.SelfEmployed ->
                                    indInfoAndEmployer

                                _ ->
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
                    , scrollUp
                    )

        ChooseOrgOrInd maybeOrgOrInd ->
            let
                employmentStatus =
                    case maybeOrgOrInd of
                        Just OrgOrInd.Org ->
                            Just EmploymentStatus.Employed

                        Just OrgOrInd.Ind ->
                            Nothing

                        _ ->
                            model.employmentStatus
            in
            ( { model | maybeOrgOrInd = maybeOrgOrInd, maybeContributorType = Nothing, employmentStatus = employmentStatus, errors = [], submitMode = False }, Cmd.none )

        UpdateOrganizationName entityName ->
            ( { model | entityName = entityName, submitMode = False }, Cmd.none )

        UpdateOrganizationClassification maybeEntityType ->
            ( { model | maybeContributorType = maybeEntityType, submitMode = False }, Cmd.none )

        UpdateOwner newOwner ->
            let
                withoutOwner =
                    List.filter (\owner -> Owner.toHash owner /= Owner.toHash newOwner) model.owners

                withNewOwner =
                    withoutOwner ++ [ newOwner ]
            in
            ( { model | owners = withNewOwner }, Cmd.none )

        DeleteOwner deletedOwner ->
            let
                newOwners =
                    List.filter (\owner -> Owner.toHash owner /= Owner.toHash deletedOwner) model.owners
            in
            ( { model | owners = newOwners }, Cmd.none )

        AddOwner ->
            let
                newOwner =
                    { firstName = model.ownerFirstName
                    , lastName = model.ownerLastName
                    , address1 = model.ownerAddress1
                    , address2 = model.ownerAddress2
                    , city = model.ownerCity
                    , state = model.ownerState
                    , postalCode = model.ownerPostalCode
                    , percentOwnership = model.ownerOwnership
                    }
            in
            case validate Owner.validator newOwner of
                Err messages ->
                    ( { model | errors = messages }, scrollUp )

                _ ->
                    let
                        totalPercentage =
                            Owner.foldOwnership model.owners + (Maybe.withDefault 0 <| String.toFloat newOwner.percentOwnership)
                    in
                    if totalPercentage > 100 then
                        ( { model | errors = [ "Total percentage exceeds 100." ] }, scrollUp )

                    else
                        ( { model
                            | owners = model.owners ++ [ newOwner ]
                            , ownerOwnership = ""
                            , ownerFirstName = ""
                            , ownerLastName = ""
                            , ownerAddress1 = ""
                            , ownerAddress2 = ""
                            , ownerCity = ""
                            , ownerState = ""
                            , ownerPostalCode = ""
                            , errors = []
                          }
                        , Cmd.none
                        )

        UpdateOwnerFirstName str ->
            ( { model | ownerFirstName = str }, Cmd.none )

        UpdateOwnerLastName str ->
            ( { model | ownerLastName = str }, Cmd.none )

        UpdateOwnerAddress1 str ->
            ( { model | ownerAddress1 = str }, Cmd.none )

        UpdateOwnerAddress2 str ->
            ( { model | ownerAddress2 = str }, Cmd.none )

        UpdateOwnerCity str ->
            ( { model | ownerCity = str }, Cmd.none )

        UpdateOwnerState str ->
            ( { model | ownerState = str }, Cmd.none )

        UpdateOwnerPostalCode str ->
            ( { model | ownerPostalCode = str }, Cmd.none )

        UpdateOwnerOwnership str ->
            ( { model | ownerOwnership = str }, Cmd.none )

        UpdatePhoneNumber str ->
            ( { model | phoneNumber = str }, sendNumber str )

        UpdateEmailAddress str ->
            ( { model | emailAddress = str }, sendEmail str )

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

        UpdateEmploymentStatus val ->
            ( { model | employmentStatus = Just val }, Cmd.none )

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
                            let
                                errorMsg =
                                    case Decode.decodeString (Decode.field "message" Decode.string) body of
                                        Ok value ->
                                            value

                                        Err err ->
                                            Copy.genericError
                            in
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
                                            ( { model | errors = [ errorMsg ], submitting = False }, Cmd.none )

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
                                                    | errors = [ errorMsg ]
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

        ToggleCardNumberVisibility bool ->
            ( { model | cardNumberIsVisible = bool }, Cmd.none )

        GotPhoneValidationRes value ->
            case decodeValue bool value of
                Ok data ->
                    ( { model | phoneNumberValidated = data }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        GotEmailValidationRes value ->
            case decodeValue bool value of
                Ok data ->
                    ( { model | emailAddressValidated = data }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ isValidNumReceiver GotPhoneValidationRes, isValidEmailReceiver GotEmailValidationRes ]


main : Program Config Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


submitDonorButtonRow : Bool -> Html Msg
submitDonorButtonRow attestation =
    Grid.row
        [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            []
            [ submitButton SubmitDonorInfo "Continue" False attestation "continueBtn" ]
        ]


donateButton : Model -> Html Msg
donateButton model =
    submitButton SubmitPaymentInfo "Donate!" model.submitting (model.submitting == False) "donateBtn"


isLLCorLLPDonor : Model -> Bool
isLLCorLLPDonor model =
    EntityType.isLLCorLLP model.maybeContributorType



-- @Todo Add validation for percentage total
-- @Todo Add ability to edit owners


manageOwnerRows : Model -> List (Html Msg)
manageOwnerRows model =
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
        ++ [ capTable model ]
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ inputText UpdateOwnerFirstName "First Name" model.ownerFirstName "contribOrgfirstName" ]
                , Grid.col
                    []
                    [ inputText UpdateOwnerLastName "Last Name" model.ownerLastName "contribOrgLastName" ]
                ]
           , Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ inputText UpdateOwnerAddress1 "Address 1" model.ownerAddress1 "contribOrgAddress1" ]
                , Grid.col
                    []
                    [ inputText UpdateOwnerAddress2 "Address 2" model.ownerAddress2 "contribOrgAddress2" ]
                ]
           , Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ inputText UpdateOwnerCity "City" model.ownerCity "contribOrgCity" ]
                , Grid.col
                    []
                    [ State.view UpdateOwnerState model.ownerState "contribOrgState" ]
                , Grid.col
                    []
                    [ inputText UpdateOwnerPostalCode "Postal Code" model.ownerPostalCode "contribOrgPostalCode" ]
                ]
           , Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ inputNumber UpdateOwnerOwnership "Percent Ownership" model.ownerOwnership "contribOrgPercentOwnership" ]
                ]
           , Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    [ Col.xs6, Col.offsetXs6 ]
                    [ submitButton AddOwner "Add another member" False True "addOwnerBtn" ]
                ]
           ]


tableBody model =
    Table.tbody [] <|
        List.map
            (\owner ->
                Table.tr []
                    [ Table.td [] [ text <| Owner.toFullName owner ]
                    , Table.td [] [ text owner.percentOwnership ]
                    , Table.td [] [ span [ onClick <| DeleteOwner owner ] [ Asset.deleteGlyph [ class "text-danger cursor-pointer" ] ] ]
                    ]
            )
            model.owners


tableHead =
    Table.simpleThead
        [ Table.th [] [ text "Name" ]
        , Table.th [] [ text "Percent Ownership" ]
        , Table.th [] [ text "" ]
        ]


capTable model =
    if List.length model.owners > 0 then
        div [] [ Table.simpleTable ( tableHead, tableBody model ) ]

    else
        div [] []


orgRows : Model -> List (Html Msg)
orgRows model =
    let
        llcRow =
            if isLLCorLLPDonor model then
                manageOwnerRows model

            else
                []
    in
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ EntityType.orgView UpdateOrganizationClassification model.maybeContributorType ]
        ]
    ]
        ++ llcRow
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ inputText UpdateOrganizationName "Organization Name" model.entityName "contribOrgPostalCode"
                    ]
                ]
           ]


mobileColSpacing : List (Attribute msg)
mobileColSpacing =
    [ Spacing.mt3, Spacing.mtAutoMd ]


piiRows : Model -> List (Html Msg)
piiRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3Md ] ]
        [ Grid.col
            [ Col.sm12, Col.md6, Col.attrs mobileColSpacing ]
            [ inputEmail UpdateEmailAddress "Email" model.emailAddress "contribIndEmail" ]
        , Grid.col
            [ Col.sm12, Col.md6, Col.attrs mobileColSpacing ]
            [ inputText UpdatePhoneNumber "Phone Number" model.phoneNumber "contribIndPhoneNumber" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3Md ] ]
        [ Grid.col
            [ Col.sm12, Col.md6, Col.attrs mobileColSpacing ]
            [ inputText UpdateFirstName "First Name" model.firstName "contribIndFirstName" ]
        , Grid.col
            [ Col.sm12, Col.md6, Col.attrs mobileColSpacing ]
            [ inputText UpdateLastName "Last Name" model.lastName "contribIndLastName" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3Md ] ]
        [ Grid.col
            [ Col.sm12, Col.md6, Col.attrs mobileColSpacing ]
            [ inputText UpdateAddress1 "Address 1" model.address1 "contribIndAddress1" ]
        , Grid.col
            [ Col.sm12, Col.md6, Col.attrs mobileColSpacing ]
            [ inputText UpdateAddress2 "Address 2" model.address2 "contribIndAddress2" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3Md ] ]
        [ Grid.col
            [ Col.sm12, Col.md4, Col.attrs mobileColSpacing ]
            [ inputText UpdateCity "City" model.city "contribIndCity" ]
        , Grid.col
            [ Col.sm12, Col.md4, Col.attrs mobileColSpacing ]
            [ State.view UpdateState model.state "contribIndState" ]
        , Grid.col
            [ Col.sm12, Col.md4, Col.attrs mobileColSpacing ]
            [ inputText UpdatePostalCode "Zip" model.postalCode "contribIndPostalCode" ]
        ]
    ]


familyRow : Model -> List (Html Msg)
familyRow model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ div [] [ text "Select your relation to the candidate:" ]
            ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
          <|
            EntityType.candidateRelationshipRadioList UpdateFamilyOrIndividual model.maybeContributorType
        ]
    ]


orgOrIndRow : Model -> List (Html Msg)
orgOrIndRow model =
    case model.settings.complianceEnabled of
        True ->
            [ Grid.row
                [ Row.attrs [ Spacing.mt2 ] ]
                [ Grid.col
                    []
                    [ text "Will I be donating as an individual or on behalf of an organization?" ]
                ]
            , Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ OrgOrInd.row ChooseOrgOrInd model.maybeOrgOrInd ]
                ]
            ]

        False ->
            []


employerOccupationRow : Model -> Html Msg
employerOccupationRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateEmployer "Employer Name" model.employer "contribIndEmployerName" ]
        , Grid.col
            []
            [ inputText UpdateOccupation "Occupation" model.occupation "contribIndOccupation" ]
        ]


employmentStatusRows : Model -> List (Html Msg)
employmentStatusRows model =
    let
        currentVal =
            EmploymentStatus.toString model.employmentStatus
    in
    case model.jurisdiction of
        Jurisdiction.MAState ->
            [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ text "Employment status:" ]
                ]
            , Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                  <|
                    Radio.radioList "employmentStatus"
                        [ SelectRadio.view (UpdateEmploymentStatus EmploymentStatus.Employed) "Employed" "Employed" <| currentVal
                        , SelectRadio.view (UpdateEmploymentStatus EmploymentStatus.Unemployed) "Unemployed" "Unemployed" <| currentVal
                        , SelectRadio.view (UpdateEmploymentStatus EmploymentStatus.Retired) "Retired" "Retired" <| currentVal
                        , SelectRadio.view (UpdateEmploymentStatus EmploymentStatus.SelfEmployed) "SelfEmployed" "Self Employed" <| currentVal
                        ]
                ]
            ]

        _ ->
            []


needEmployerName : Maybe EmploymentStatus -> Bool
needEmployerName val =
    case val of
        Just EmploymentStatus.Employed ->
            True

        Just EmploymentStatus.SelfEmployed ->
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
            []
            [ inputToggleSecure
                UpdateCardNumber
                "Card Number*"
                model.cardNumber
                model.cardNumberIsVisible
                ToggleCardNumberVisibility
                "Card Number"
                "contribCCNumber"
            ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3Md ] ]
        [ Grid.col
            [ Col.xs12, Col.md4, Col.attrs mobileColSpacing ]
            [ inputNumber UpdateExpirationMonth "MM*" model.expirationMonth "contribCCM" ]
        , Grid.col
            [ Col.xs12, Col.md4, Col.attrs mobileColSpacing ]
            [ inputNumber UpdateExpirationYear "YYYY*" model.expirationYear "contribCCY" ]
        , Grid.col
            [ Col.xs12, Col.md4, Col.attrs mobileColSpacing ]
            [ inputSecure UpdateCVV "CVV*" model.cvv "contribCCV" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col
            [ Col.md ]
            donateButtonOrNot
        ]
    ]


attestationRow : Model -> List (Html Msg)
attestationRow model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt5 ] ]
        [ Grid.col
            []
            [ Checkbox.advancedCheckbox
                [ Checkbox.id "attestation"
                , Checkbox.checked model.attestation
                , Checkbox.onCheck UpdateAttestation
                ]
                (Checkbox.label [ attribute "data-cy" "contribAffirm" ] [ text "By making this contribution I affirm that:" ])
            ]
        ]
    , Grid.row [ Row.attrs [ Spacing.mt1 ] ]
        [ Grid.col
            []
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


postalCodeValidator : Validator String Model
postalCodeValidator =
    fromErrors postalCodeToErrors


phoneNumValidator : Validator String Model
phoneNumValidator =
    fromErrors phoneNumToErrors


emailAddressValidator : Validator String Model
emailAddressValidator =
    fromErrors emailAddressToErrors


ownersPercentageValidator : Validator String Model
ownersPercentageValidator =
    fromErrors ownersPercentageToErrors


postalCodeToErrors : Model -> List String
postalCodeToErrors model =
    let
        length =
            String.length <| model.postalCode
    in
    if length < 5 then
        [ "ZIP code is too short." ]

    else if length > 9 then
        [ "ZIP code is too long." ]

    else
        []


phoneNumToErrors : Model -> List String
phoneNumToErrors model =
    if String.length model.phoneNumber == 0 then
        []

    else if model.phoneNumberValidated then
        []

    else
        [ "Phone number is invalid" ]


emailAddressToErrors : Model -> List String
emailAddressToErrors model =
    if model.emailAddressValidated == True then
        []

    else
        [ "Email Address is invalid" ]


ownersPercentageToErrors : Model -> List String
ownersPercentageToErrors model =
    let
        totalPercentage =
            Owner.foldOwnership model.owners
    in
    if totalPercentage /= 100 then
        [ "Total Percent ownership must equal 100%" ]

    else
        []


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
        , postalCodeValidator
        , phoneNumValidator
        , emailAddressValidator
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
    Validate.firstError [ piiValidator, familyValidator, employmentStatusValidator ]


indInfoAndEmployer : Validator String Model
indInfoAndEmployer =
    Validate.firstError [ piiValidator, familyValidator, employmentStatusValidator, employerValidator ]


employmentStatusValidator : Validator String Model
employmentStatusValidator =
    fromErrors employmentStatusToErrors


employmentStatusToErrors : Model -> List String
employmentStatusToErrors model =
    case model.jurisdiction of
        Jurisdiction.MAState ->
            case model.employmentStatus of
                Nothing ->
                    [ "Please specify your employment status" ]

                _ ->
                    []

        Jurisdiction.NYState ->
            []


employerValidator : Validator String Model
employerValidator =
    Validate.all
        [ ifBlank .employer "Please specify your employer."
        , ifBlank .occupation "Please specify your occupation."
        ]


orgInfoValidator : Model -> Validator String Model
orgInfoValidator model =
    let
        extra =
            if isLLCorLLPDonor model then
                [ ifEmptyList .owners "Please specify the ownership breakdown for your LLC."
                , ownersPercentageValidator
                ]

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


encodeContribution : Model -> Encode.Value
encodeContribution model =
    Encode.object <|
        [ ( "committeeId", Encode.string model.committeeId )
        , ( "amount", Encode.int <| dollarStringToCents model.amount )
        , ( "firstName", Encode.string model.firstName )
        , ( "lastName", Encode.string model.lastName )
        , ( "addressLine1", Encode.string model.address1 )
        , ( "city", Encode.string model.city )
        , ( "state", Encode.string <| String.toUpper model.state )
        , ( "postalCode", Encode.string model.postalCode )
        , ( "entityType", Encode.string <| EntityType.toDataString <| Maybe.withDefault EntityType.llc model.maybeContributorType )
        , ( "emailAddress", Encode.string model.emailAddress )
        , ( "cardNumber", Encode.string model.cardNumber )
        , ( "cardExpirationMonth", Encode.int <| numberStringToInt model.expirationMonth )
        , ( "cardExpirationYear", Encode.int <| numberStringToInt model.expirationYear )
        , ( "cardCVC", Encode.string model.cvv )
        , ( "attestsToBeingAnAdultCitizen", Encode.bool model.attestation )

        --, ( "middleName", Encode.string model.middleName )
        ]
            ++ optionalString "employmentStatus" (EmploymentStatus.toString model.employmentStatus)
            ++ optionalString "entityName" model.entityName
            ++ optionalString "employer" model.employer
            ++ optionalString "occupation" model.occupation
            ++ optionalString "refCode" model.ref
            ++ optionalString "addressLine2" model.address2
            ++ optionalFieldOwners "owners" (Just model.owners)


optionalString : String -> String -> List ( String, Value )
optionalString key val =
    if val == "" then
        []

    else
        [ ( key, Encode.string val ) ]


optionalFieldOwners : String -> Maybe Owner.Owners -> List ( String, Value )
optionalFieldOwners key val =
    if val == Just [] then
        []

    else
        [ ( key, Encode.list Owner.encoder <| Maybe.withDefault [] val ) ]


numberStringToInt : String -> Int
numberStringToInt =
    String.toInt >> Maybe.withDefault 0


dollarStringToCents : String -> Int
dollarStringToCents =
    String.toFloat >> Maybe.withDefault 0 >> (*) 100 >> round


postContribution : Model -> Cmd Msg
postContribution model =
    post
        { url = model.endpoint
        , body = jsonBody <| encodeContribution model
        , expect =
            Http.Detailed.expectString GotAPIResponseContribute
        }
