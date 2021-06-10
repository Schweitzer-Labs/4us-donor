module CommitteePage exposing (view)

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Copy
import Html exposing (Html, div, h1, h2, h4, h5, img, p, text)
import Html.Attributes exposing (class, href, src)


view : String -> Html msg -> Html msg
view committeeId form =
    case committeeId of
        "john-safford" ->
            div
                [ Spacing.pl2Md, Spacing.pr2Md ]
                [ div [ class "text-center", Spacing.p5 ] [ h1 [ Spacing.pl3, Spacing.pl4Md, class "bigger-than-h1" ] [ text Copy.promoHeading ] ]
                , Grid.containerFluid
                    []
                    [ Grid.row
                        [ Row.attrs [ Spacing.ml5Md, Spacing.mr5Md, Spacing.mb5 ] ]
                        [ Grid.col
                            [ Col.md6, Col.attrs [], Col.orderXs2, Col.orderMd1 ]
                            [ p [ class "text-black" ] [ Copy.promoContent ]
                            , div [] [ img [ Asset.src Asset.johnSaffordHeadShot, class "w-100" ] [] ]
                            ]
                        , Grid.col
                            [ Col.md6, Col.attrs [], Col.orderXs1, Col.orderMd2 ]
                            [ form ]
                        ]
                    ]
                ]

        _ ->
            div [] []
