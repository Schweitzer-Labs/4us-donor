module Content.WillSchweitzer exposing (arthurEmailAddress, emailBody, emailSubject, firstCopy, firstHeading, promoContent, promoHeading, secondCopy, secondHeading, thirdCopy, thirdHeading)

import Bootstrap.Utilities.Spacing as Spacing
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
    text "Josh Allen for Governor"


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
            [ text "Fight, Wyoming, Fight" ]
        , div
            []
            [ div [] [ text "Come on, Cowboys, gold and brown!" ]
            , div [] [ text "Show them how, boys, hold them down!" ]
            , div [] [ text "Start right now, boys, don't' delay," ]
            , div [] [ text "Break away, win today." ]
            , div [] [ text "Take that ball, and one, two, three!" ]
            , div [] [ text "Carry on triumphantly -- Come on and fight!" ]
            , div [] [ text "Fight! Fight, you Cowboys, fight!" ]
            , div [] [ text "Come on and fight to victory!" ]
            ]
        ]
