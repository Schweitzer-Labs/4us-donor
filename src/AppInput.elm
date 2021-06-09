module AppInput exposing (inputEmail, inputMonth, inputNumber, inputSecure, inputText, inputToggleSecure)

import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Input as Input
import Html exposing (Html, div)


inputNumber : (String -> msg) -> String -> String -> Html msg
inputNumber msg placeholder val =
    Input.text
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputMonth : (String -> msg) -> String -> String -> Html msg
inputMonth msg placeholder val =
    Input.month
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputText : (String -> msg) -> String -> String -> Html msg
inputText msg placeholder val =
    Input.text
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputSecure : (String -> msg) -> String -> String -> Html msg
inputSecure msg placeholder val =
    Input.password
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputToggleSecure : (String -> msg) -> String -> String -> Bool -> (Bool -> msg) -> Html msg
inputToggleSecure msg placeholder val isVisible toVisibleMsg =
    let
        inputType =
            if isVisible then
                Input.text

            else
                Input.password
    in
    div
        []
        [ inputType
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            ]
        , Checkbox.checkbox
            [ Checkbox.checked isVisible
            , Checkbox.onCheck toVisibleMsg
            ]
            "Show Card Number"
        ]


inputEmail : (String -> msg) -> String -> String -> Html msg
inputEmail msg placeholder val =
    Input.email
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]
