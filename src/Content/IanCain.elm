module Content.IanCain exposing (firstCopy, firstHeading, footerCopy, promoContent, promoHeading)

import Asset
import Bootstrap.Utilities.Spacing as Spacing
import Content.Generic exposing (promoCopyFormatter)
import Html exposing (Html, div, h4, h5, img, li, ol, p, text)
import Html.Attributes exposing (class)


promoHeading : Html msg
promoHeading =
    img [ Asset.src Asset.ianCainLogo, class "w-100" ] []


firstHeading =
    "Donate to The Cain Committee"


firstCopy =
    "Your contribution will allow us to do all that we need to make sure that Ian will continue to be YOUR elected representative, and address the needs of the community. We are truly grateful for your support!"


promoContent : Html msg
promoContent =
    div
        []
        (promoCopyFormatter firstHeading firstCopy)


footerCopy : List (Html msg)
footerCopy =
    [ div [ Spacing.p4 ]
        [ h5 [ class "font-weight-heavy" ] [ text "Contribution rules" ]
        , ol []
            [ li [] [ text "I am at least eighteen years old." ]
            , li [] [ text "This contribution is made from my own funds, and funds are not being provided to me by another person or entity for the purpose of making this contribution." ]
            , li [] [ text "I am a U.S. citizen or lawfully admitted permanent resident (i.e., green card holder)." ]
            , li [] [ text "I am making this contribution with my own personal credit card and not with a corporate or business credit card or a card issued to another person." ]
            ]
        , p [] [ text "In accordance with OCPF regulations individuals may contribute up to $1,000 annually to a candidate. Spouses may contribute jointly provided that both names are pre-printed on the check. All contributions over $200 require employer/occupation information. Lobbyists are limited to $200 annually to a candidate. Corporate and LLC contributions are prohibited. Money order and bank check contributions are limited to $100 per person per year." ]
        , p [] [ text "Cash contributions are limited to $50 per person per year." ]
        , p [] [ text "Donations are not deductible for income tax purposes." ]
        ]
    ]
