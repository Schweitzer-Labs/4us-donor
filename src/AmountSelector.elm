module AmountSelector exposing (view)

import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div)
import SelectButton exposing (selectButton)


view : (String -> msg) -> String -> Html msg
view msg currentVal =
    Grid.containerFluid
        []
        [ Grid.row
            []
            [ Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton msg "$10" "10" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton msg "$25" "25" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton msg "$50" "50" currentVal ]
            , Grid.col
                []
                [ selectButton msg "$100" "100" currentVal ]
            ]
        , Grid.row
            []
            [ Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton msg "$150" "150" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton msg "$250" "250" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton msg "$1000" "1000" currentVal ]
            , Grid.col
                []
                [ div [ Spacing.mt4 ] [ Input.number [ Input.onInput msg ] ] ]
            ]
        ]
