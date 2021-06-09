module SubmitButton exposing (submitButton)

import Bootstrap.Button as Button
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, text)


submitButton : msg -> String -> Bool -> Bool -> Html msg
submitButton msg buttonText loading enabled =
    Button.button
        [ Button.success
        , Button.block
        , Button.onClick msg
        , Button.disabled (enabled == False)
        , Button.attrs [ Spacing.p2 ]
        ]
        [ if loading then
            Spinner.spinner
                [ Spinner.small
                ]
                [ Spinner.srMessage "Loading..."
                ]

          else
            text buttonText
        ]
