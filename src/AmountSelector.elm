module AmountSelector exposing (view)

import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div)
import SelectButton exposing (selectButton)
import SubmitButton exposing (submitButton)


view : (String -> msg) -> String -> msg -> Html msg
view selectMsg currentVal submitMsg =
    Grid.containerFluid
        []
        [ Grid.row
            []
            [ Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton selectMsg "$10" "10" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton selectMsg "$25" "25" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton selectMsg "$50" "50" currentVal ]
            , Grid.col
                []
                [ selectButton selectMsg "$100" "100" currentVal ]
            ]
        , Grid.row
            []
            [ Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton selectMsg "$150" "150" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton selectMsg "$250" "250" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ] ]
                [ selectButton selectMsg "$1000" "1000" currentVal ]
            , Grid.col
                []
                [ div [ Spacing.mt4 ] [ Input.number [ Input.onInput selectMsg ] ] ]
            ]
        , Grid.row
            [ Row.attrs [ Spacing.mt5 ] ]
            [ Grid.col
                []
                [ submitButton submitMsg "Continue" False True ]
            ]
        ]
