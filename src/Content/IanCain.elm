module Content.IanCain exposing (firstCopy, firstHeading, promoContent, promoHeading)

import Content.Generic exposing (promoCopyFormatter)
import Html exposing (Html, div, h4, text)


promoHeading : String
promoHeading =
    "Ian Cain for Ward 3"


firstHeading =
    "Donate to The Cain Committee"


firstCopy =
    "Your contribution will allow us to do all that we need to make sure that Ian will continue to be YOUR elected representative, and address the needs of the community. We are truly grateful for your support!"


promoContent : Html msg
promoContent =
    div
        []
        (promoCopyFormatter firstHeading firstCopy)
