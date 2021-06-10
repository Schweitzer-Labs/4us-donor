module SelectRadio exposing (view)

import Bootstrap.Form.Radio as Radio exposing (Radio)


view : msg -> String -> String -> String -> Radio msg
view msg dataValue displayValue currentValue =
    Radio.createCustom
        [ Radio.id dataValue
        , Radio.inline
        , Radio.onClick msg
        , Radio.checked (currentValue == dataValue)
        ]
        displayValue
