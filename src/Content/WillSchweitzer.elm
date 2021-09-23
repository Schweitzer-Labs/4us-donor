module Content.WillSchweitzer exposing (arthurEmailAddress, emailBody, emailSubject, firstCopy, firstHeading, promoContent, promoHeading, secondCopy, secondHeading, thirdCopy, thirdHeading)

import Bootstrap.Utilities.Spacing as Spacing
import Content.Generic exposing (promoCopyFormatter)
import Html exposing (Html, div, h4, li, text)


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
    text "Shana Harmongoff for Senator"


firstHeading =
    "Fight, Wyoming, Fight"


firstCopy =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."


secondHeading =
    "Go"


secondCopy =
    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."


thirdHeading =
    "Buffalo"


thirdCopy =
    "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."



--promoContent : Html msg
--promoContent =
--    div
--        []
--        (promoCopyFormatter firstHeading firstCopy
--            ++ promoCopyFormatter secondHeading secondCopy
--            ++ promoCopyFormatter thirdHeading thirdCopy
--        )


promoContent : Html msg
promoContent =
    div []
        [ h4
            [ Spacing.mt3 ]
            [ text "Your Neighbor, Your Voice" ]
        , div [] [ text "As your neighbor and your voice in the New York State Senate Shana Harmongoff will..." ]
        , div
            []
            [ li [] [ text "Champion an Equitable COVID19 Response" ]
            , li [] [ text "Advocate for Seniors" ]
            , li [] [ text "Support Small Businesses" ]
            , li [] [ text "Protect LGBTQ+ Rights" ]
            , li [] [ text "Fight for Quality Education" ]
            , li [] [ text "Enforce an End to Domestic Violence" ]
            , li [] [ text "Reform the Criminal Justice System" ]
            , li [] [ text "Improve Public Safety and Transportation" ]
            , li [] [ text "Address Mental Healthcare, Healthcare Disparities & Substance Abuse Issues" ]
            , li [] [ text "Act to prevent Homelessness and Ensure Access to Affordable Housing" ]
            , li [] [ text "Secure Economic Justice & Worker Rights for Essential Workers" ]
            , li [] [ text "Combat Climate Change and End Environmental Racism" ]
            ]
        ]
