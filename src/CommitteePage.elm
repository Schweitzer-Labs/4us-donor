module CommitteePage exposing (view)

import Asset exposing (Image)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Content.IanCain as IanCain
import Content.JohnSafford as JohnSafford
import Content.WillSchweitzer as WillSchweitzer
import Html exposing (Html, div, h1, img, p, text)
import Html.Attributes exposing (class)


view : String -> Html msg -> Html msg
view committeeId form =
    case committeeId of
        "john-safford" ->
            committeePage JohnSafford.promoContent JohnSafford.promoHeading Asset.johnSaffordHeadShot form

        "ian-cain" ->
            committeePage IanCain.promoContent IanCain.promoHeading Asset.ianCainHeadshot form

        _ ->
            committeePage WillSchweitzer.promoContent WillSchweitzer.promoHeading Asset.placeholderHeadshot form


committeePage : Html msg -> String -> Image -> Html msg -> Html msg
committeePage promoCopy promoHeading headshot form =
    div
        [ Spacing.pl2Md, Spacing.pr2Md ]
        [ div [ class "text-center", Spacing.p5 ] [ h1 [ Spacing.pl3, Spacing.pl4Md, class "bigger-than-h1" ] [ text promoHeading ] ]
        , Grid.containerFluid
            []
            [ Grid.row
                [ Row.attrs [ Spacing.ml5Md, Spacing.mr5Md, Spacing.mb5 ] ]
                [ Grid.col
                    [ Col.md6, Col.attrs [], Col.orderXs2, Col.orderMd1 ]
                    [ p [ class "text-black" ] [ promoCopy ]
                    , div [] [ img [ Asset.src headshot, class "w-100" ] [] ]
                    ]
                , Grid.col
                    [ Col.md6, Col.attrs [], Col.orderXs1, Col.orderMd2 ]
                    [ form ]
                ]
            ]
        ]
