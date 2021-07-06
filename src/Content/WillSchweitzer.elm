module Content.WillSchweitzer exposing (arthurEmailAddress, emailBody, emailSubject, firstCopy, firstHeading, promoContent, promoHeading, secondCopy, secondHeading, thirdCopy, thirdHeading)

import Content.Generic exposing (promoCopyFormatter)
import Html exposing (Html, div, h4, text)


arthurEmailAddress : String
arthurEmailAddress =
    "arthur@4us.net"


emailSubject : String
emailSubject =
    "Maxed-out Arthur"


emailBody : String
emailBody =
    "I’d like to donate more but I’ve reached the limit."


promoHeading : Html msg
promoHeading =
    text "Will Schweitzer for Supervisor"


firstHeading =
    "Capable"


firstCopy =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."


secondHeading =
    "Responsible"


secondCopy =
    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."


thirdHeading =
    "Considerate"


thirdCopy =
    "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."


promoContent : Html msg
promoContent =
    div
        []
        (promoCopyFormatter firstHeading firstCopy
            ++ promoCopyFormatter secondHeading secondCopy
            ++ promoCopyFormatter thirdHeading thirdCopy
        )
