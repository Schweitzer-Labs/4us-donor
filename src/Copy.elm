module Copy exposing (attestation, currentDonationExceedsLimit, genericError, paymentProcessingFailure, reachedMaximumContribution)

import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, br, div, h4, text)


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


attestation : List (Html msg)
attestation =
    List.intersperse (br [] []) <|
        List.map (\n -> div [ Spacing.mt1, Spacing.ml2 ] [ text n ])
            [ "1. I am at least eighteen years old."
            , "2. This contribution is made from my own funds, and funds are not being provided to me by another person or entity for the purpose of making this contribution. "
            , "3. I am a U.S. citizen or lawfully admitted permanent resident (i.e., green card holder)."
            , "4. I am making this contribution with my own personal credit card and not with a corporate or business credit card or a card issued to another person. "
            ]
