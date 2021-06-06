module CommitteePage exposing (view)

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, h1, h4, img, text)
import Html.Attributes exposing (class, href)


view : Html msg -> Html msg
view form =
    div
        []
        [ div [ class "text-center" ] [ img [ Asset.src Asset.arthurLogo, class "width-200px" ] [] ]
        , Grid.containerFluid
            []
            [ Grid.row
                []
                [ Grid.col
                    [ Col.xs6, Col.attrs [ Spacing.p5 ] ]
                    [ h4 [ class "bg-transparent-white text-black", Spacing.p4 ] [ text promoCopy ] ]
                , Grid.col
                    [ Col.xs6, Col.attrs [ Spacing.p5 ] ]
                    [ form ]
                ]
            ]
        ]


promoCopy : String
promoCopy =
    """
If there's one thing the people of Essex County can agree on, it's that a little bit can go a long way.
Please join Arthur by contributing even the smallest amount you can.
"""
