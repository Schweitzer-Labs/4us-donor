module Content.Generic exposing (genericError, paymentProcessingFailure, promoCopyFormatter)

import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, h4, text)


genericError =
    "Oops! Something went wrong. Please try again later"


paymentProcessingFailure =
    "Payment could not be processed. Please ensure payment details are correct."


promoCopyFormatter : String -> String -> List (Html msg)
promoCopyFormatter heading copy =
    [ h4
        [ Spacing.mt3 ]
        [ text heading ]
    , div
        []
        [ text copy ]
    ]


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
