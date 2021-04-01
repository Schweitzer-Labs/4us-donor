module Progress exposing (Progress(..), iconCol, lineCol, progressCols, view)

import Asset exposing (Image)
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, img, span)
import Html.Attributes exposing (class)


type Progress
    = AccountSettings
    | Plaid
    | Finicity
    | Stripe
    | Complete


view : Progress -> Html msg
view progress =
    Grid.containerFluid
        [ Spacing.mt4, Spacing.mb3 ]
        [ Grid.row
            [ Row.centerXs ]
          <|
            progressCols progress
        ]


progressCols : Progress -> List (Column msg)
progressCols progress =
    case progress of
        AccountSettings ->
            [ iconCol Asset.profileCircle
            , lineCol False
            , iconCol Asset.plaidCircle
            , lineCol False
            , iconCol Asset.finicityCircle
            , lineCol False
            , iconCol Asset.stripeCircle
            , lineCol False
            , iconCol Asset.checkCircle
            ]

        Plaid ->
            [ iconCol Asset.profileCircle
            , lineCol True
            , iconCol Asset.plaidCircleSelected
            , lineCol False
            , iconCol Asset.finicityCircle
            , lineCol False
            , iconCol Asset.stripeCircle
            , lineCol False
            , iconCol Asset.checkCircle
            ]

        Finicity ->
            [ iconCol Asset.profileCircle
            , lineCol True
            , iconCol Asset.plaidCircleSelected
            , lineCol True
            , iconCol Asset.finicityCircleSelected
            , lineCol False
            , iconCol Asset.stripeCircle
            , lineCol False
            , iconCol Asset.checkCircle
            ]

        Stripe ->
            [ iconCol Asset.profileCircle
            , lineCol True
            , iconCol Asset.plaidCircleSelected
            , lineCol True
            , iconCol Asset.finicityCircleSelected
            , lineCol True
            , iconCol Asset.stripeCircleSelected
            , lineCol False
            , iconCol Asset.checkCircle
            ]

        Complete ->
            [ iconCol Asset.profileCircle
            , lineCol True
            , iconCol Asset.plaidCircleSelected
            , lineCol True
            , iconCol Asset.finicityCircleSelected
            , lineCol True
            , iconCol Asset.stripeCircleSelected
            , lineCol True
            , iconCol Asset.checkCircleSelected
            ]


iconCol : Image -> Column msg
iconCol image =
    Grid.col [ Col.attrs [ class "text-center" ] ] [ img [ Asset.src image ] [] ]


lineCol : Bool -> Column msg
lineCol selected =
    Grid.col
        [ Col.attrs [ class "align-middle", Spacing.pr0, Spacing.pl0 ] ]
        [ span
            []
            [ img
                [ Asset.src
                    (if selected then
                        Asset.lineSelected

                     else
                        Asset.lineUnselected
                    )
                ]
                []
            ]
        ]
