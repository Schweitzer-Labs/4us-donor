module Content.JohnSafford exposing (firstCopy, firstHeading, promoContent, promoHeading, secondCopy, secondHeading, thirdCopy, thirdHeading)

import Content.Generic exposing (promoCopyFormatter)
import Html exposing (Html, div, h4, text)


promoHeading : Html msg
promoHeading =
    text "John Safford for Supervisor"


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


promoContent : Html msg
promoContent =
    div
        []
        (promoCopyFormatter firstHeading firstCopy
            ++ promoCopyFormatter secondHeading secondCopy
            ++ promoCopyFormatter thirdHeading thirdCopy
        )
