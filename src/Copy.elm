module Copy exposing (attestation, contributionEmailHref, currentDonationExceedsLimit, emailBody, genericError, paymentProcessingFailure, promoContent, promoHeading, reachedMaximumContribution)

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


promoHeading : String
promoHeading =
    "John Safford for Supervisor"


firstHeading =
    "Capable"


firstCopy =
    "I make situations better. I have grown over seven businesses from zero to success and have employed dozens of individuals in productive satisfying work. I currently manage hundreds of thousands of dollars in budgets for demanding sophisticated communities. I am confident in my ability to improve any team I interact with."


secondHeading =
    "Responsible"


secondCopy =
    "I own both wins and losses. I am able to admit mistakes and learn from them but a mistake does not deter me from making decisions when they need to be made. This is what we need at the county right now."


thirdHeading =
    "Considerate"


thirdCopy =
    "Concerning people, I constantly train my mind to look to the inside rather than the outside. I look for character rather than outward form. For me, it is the second thought that counts. However this kind of consideration requires concentration and an ability to listen carefully."


promoCopyFormatter : String -> String -> List (Html msg)
promoCopyFormatter heading copy =
    [ h4
        [ Spacing.mt3 ]
        [ text heading ]
    , div
        []
        [ text copy ]
    ]


promoContent : Html msg
promoContent =
    div
        []
        (promoCopyFormatter firstHeading firstCopy
            ++ promoCopyFormatter secondHeading secondCopy
            ++ promoCopyFormatter thirdHeading thirdCopy
        )
