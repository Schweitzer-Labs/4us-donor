module CommitteePage exposing (view)

import Asset exposing (Image)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Content.IanCain as IanCain
import Content.JohnSafford as JohnSafford
import Content.LuisSepulveda as LuisSepulveda
import Content.WillSchweitzer as WillSchweitzer
import Html exposing (Html, div, h1, img, p, text)
import Html.Attributes exposing (class)


view : String -> Html msg -> { title : String, body : List (Html msg) }
view committeeId form =
    -- @Todo formulate less hacky approach to catch demo committees
    if String.length committeeId >= 20 then
        { title = "Will Schweitzer Committee", body = committeePage WillSchweitzer.promoContent WillSchweitzer.promoHeading Asset.placeholderHeadshot form }

    else
        case committeeId of
            "john-safford" ->
                { title = "John Safford Committee", body = committeePage JohnSafford.promoContent JohnSafford.promoHeading Asset.johnSaffordHeadShot form }

            "ian-cain" ->
                { title = "Ian Cain Committee", body = committeePage IanCain.promoContent IanCain.promoHeading Asset.ianCainHeadshot form }

            "will-schweitzer" ->
                { title = "Will Schweitzer Committee", body = committeePage WillSchweitzer.promoContent WillSchweitzer.promoHeading Asset.placeholderHeadshot form }

            "luis-r-sepulveda" ->
                { title = "Luis R. Sepulveda Committee", body = committeePage LuisSepulveda.promoContent LuisSepulveda.promoHeading Asset.luisSepulvedaHeadshot form }

            _ ->
                { title = "Committee not found", body = [ div [] [ h1 [ class "text-center", Spacing.mt5 ] [ text "Committee not found" ] ] ] }


committeePage : Html msg -> Html msg -> Image -> Html msg -> List (Html msg)
committeePage promoCopy promoHeading headshot form =
    [ div
        [ Spacing.pl2Md, Spacing.pr2Md ]
        [ div [ class "text-center", Spacing.p5 ] [ h1 [ Spacing.pl3, Spacing.pl4Md, class "bigger-than-h1" ] [ promoHeading ] ]
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
    ]
