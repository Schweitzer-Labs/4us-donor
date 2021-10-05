module AppInput exposing (inputEmail, inputMonth, inputNumber, inputSecure, inputText, inputToggleSecure)

import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Input as Input
import Html exposing (Html, div, text)
import Html.Attributes exposing (attribute, class)


inputNumber : (String -> msg) -> String -> String -> String -> String -> Html msg
inputNumber msg placeholder val label testAttr =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.text
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            , Input.attrs [ attribute "data-cy" testAttr ]
            ]
        ]


inputMonth : (String -> msg) -> String -> String -> Html msg
inputMonth msg placeholder val =
    Input.month
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputText : (String -> msg) -> String -> String -> String -> String -> Html msg
inputText msg placeholder val label testAttr =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.text
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            , Input.attrs [ attribute "data-cy" testAttr ]
            ]
        ]


inputSecure : (String -> msg) -> String -> String -> String -> String -> Html msg
inputSecure msg placeholder val label testAttr =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.password
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            , Input.attrs [ attribute "data-cy" testAttr ]
            ]
        ]


inputToggleSecure : (String -> msg) -> String -> String -> Bool -> (Bool -> msg) -> String -> String -> Html msg
inputToggleSecure msg placeholder val isVisible toVisibleMsg label testAttr =
    let
        inputType =
            if isVisible then
                Input.text

            else
                Input.password
    in
    Form.group
        []
        [ Form.label [] [ text label ]
        , inputType
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            , Input.attrs [ attribute "data-cy" testAttr ]
            ]
        , Checkbox.checkbox
            [ Checkbox.checked isVisible
            , Checkbox.onCheck toVisibleMsg
            ]
            "Show Card Number"
        ]


inputEmail : (String -> msg) -> String -> String -> String -> String -> Html msg
inputEmail msg placeholder val label testAttr =
    Form.group []
        [ Form.label [ class "font-weight-light" ] [ text label ]
        , Input.email
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            , Input.attrs [ attribute "data-cy" testAttr ]
            ]
        ]
