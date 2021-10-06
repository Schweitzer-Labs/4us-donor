module SubmitButton exposing (submitButton)

import Bootstrap.Button as Button
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, text)
import Html.Attributes exposing (attribute)


submitButton : msg -> String -> Bool -> Bool -> String -> Html msg
submitButton msg buttonText loading enabled testAttr =
    Button.button
        [ Button.success
        , Button.block
        , Button.onClick msg
        , Button.disabled (enabled == False)
        , Button.attrs [ Spacing.p2, attribute "data-cy" testAttr ]
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
