module AmountSelector exposing (view)

import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, text)
import SelectButton exposing (selectButton)
import SubmitButton exposing (submitButton)


view : (String -> msg) -> String -> msg -> Bool -> Html msg
view selectMsg currentVal submitMsg buttonVisible =
    let
        buttonRow =
            if buttonVisible then
                [ Grid.row
                    [ Row.attrs [ Spacing.mt3 ] ]
                    [ Grid.col
                        []
                        [ submitButton submitMsg "Continue" False True ]
                    ]
                ]

            else
                []
    in
    Grid.containerFluid
        [ Spacing.pr1, Spacing.pl0 ]
        ([ Grid.row
            [ Row.centerMd ]
            [ Grid.col
                [ Col.attrs [ Spacing.pr0 ], Col.md3, Col.xs6 ]
                [ selectButton selectMsg "$10" "10" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ], Col.md3, Col.xs6 ]
                [ selectButton selectMsg "$25" "25" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ], Col.md3, Col.xs6 ]
                [ selectButton selectMsg "$50" "50" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ], Col.md3, Col.xs6 ]
                [ selectButton selectMsg "$100" "100" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ], Col.md3, Col.xs6 ]
                [ selectButton selectMsg "$150" "150" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ], Col.md3, Col.xs6 ]
                [ selectButton selectMsg "$250" "250" currentVal ]
            , Grid.col
                [ Col.attrs [ Spacing.pr0 ], Col.md3, Col.xs6 ]
                [ selectButton selectMsg "$1000" "1000" currentVal ]
            , Grid.col
                [ Col.md3, Col.xs6 ]
                [ div [ Spacing.mt4 ] [ Input.number [ Input.onInput selectMsg ] ] ]
            ]
         ]
            ++ buttonRow
        )
