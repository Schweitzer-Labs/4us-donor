module Copy exposing (attestation, contributionEmailHref, currentDonationExceedsLimit, emailBody, genericError, paymentProcessingFailure, reachedMaximumContribution)

import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, h4, text)
import Mailto exposing (Mailto, body, subject)


genericError =
    "Oops! Something went wrong. Please try again later"


paymentProcessingFailure =
    "Payment could not be processed. Please ensure payment details are correct."


currentDonationExceedsLimit : Int -> String
currentDonationExceedsLimit remaining =
    let
        remainingString =
            String.fromFloat <| toFloat remaining / 100
    in
    "Your current donation exceeds the donation limit. You may donate up to $" ++ remainingString ++ "."


reachedMaximumContribution : String
reachedMaximumContribution =
    "You have reached the maximum contribution limit for our committee. Our team will contact you regarding further contribution methods."


arthurEmailAddress : String
arthurEmailAddress =
    "arthur@4us.net"


emailSubject : String
emailSubject =
    "Maxed-out Arthur"


emailBody : String
emailBody =
    "I’d like to donate more but I’ve reached the limit."


contributionEmailHref : Mailto
contributionEmailHref =
    Mailto.mailto arthurEmailAddress
        |> subject emailSubject
        |> body emailBody


attestation : String
attestation =
    "By checking this box I am confirming that I am an American citizen and at least eighteen years of age."


promoCopyFormatter : String -> String -> List (Html msg)
promoCopyFormatter heading copy =
    [ h4
        [ Spacing.mt3 ]
        [ text heading ]
    , div
        []
        [ text copy ]
    ]
