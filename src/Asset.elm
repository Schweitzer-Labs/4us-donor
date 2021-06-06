module Asset exposing (Glyph(..), Image(..), amalgamatedLogo, arthurLogo, bellGlyph, binoculars, blockchainDiamond, calendar, checkCircle, checkCircleSelected, circleCheckGlyph, coinsGlyph, defaultAvatar, documents, eightX, error, finicityCircle, finicityCircleSelected, gearHires, genderNeutral, glyph, house, image, lineSelected, lineUnselected, linkGlyph, loading, minusCircleGlyph, person, plaidCircle, plaidCircleSelected, profileCircle, sackDollarGlyph, search, searchDollarGlyph, src, stripeCircle, stripeCircleSelected, stripeLogo, tbdBankLogo, universityGlyph, usLogo, usLogoWing, userGlyph, wiseLogo)

{-| Assets, such as images, videos, and audio. (We only have images for now.)

We should never expose asset URLs directly; this module should be in charge of
all of them. One source of truth!

-}

import Html exposing (Attribute, Html, i)
import Html.Attributes as Attr exposing (class)


type Image
    = Image String



-- IMAGES


error : Image
error =
    image "error.jpg"


amalgamatedLogo : Image
amalgamatedLogo =
    image "amalgamated-bank-logo.png"


wiseLogo : Image
wiseLogo =
    image "wise-bank-logo.png"


usLogo : Image
usLogo =
    image "logo-hires.png"


usLogoWing : Image
usLogoWing =
    image "logo-hires-wing.png"


blockchainDiamond : Image
blockchainDiamond =
    image "blockchain-diamond.png"


gearHires : Image
gearHires =
    image "gear-hires.png"


search : Image
search =
    image "search.png"


calendar : Image
calendar =
    image "calendar.png"


person : Image
person =
    image "person.png"


house : Image
house =
    image "house.png"


eightX : Image
eightX =
    image "eight-x.png"


binoculars : Image
binoculars =
    image "binoculars.png"


stripeLogo : Image
stripeLogo =
    image "stripe-logo.png"


documents : Image
documents =
    image "documents.png"


arthurLogo : Image
arthurLogo =
    image "arthur_logo.png"


loading : Image
loading =
    image "loading.svg"


defaultAvatar : Image
defaultAvatar =
    image "smiley-cyrus.jpg"


genderNeutral : Bool -> Image
genderNeutral selected =
    if selected then
        image "gender-neutral-selected.svg"

    else
        image "gender-neutral.svg"


tbdBankLogo : Image
tbdBankLogo =
    image "tbd-bank-logo.svg"


profileCircle : Image
profileCircle =
    image "profile-circle.svg"


plaidCircle : Image
plaidCircle =
    image "plaid-circle.svg"


plaidCircleSelected : Image
plaidCircleSelected =
    image "plaid-circle-selected.svg"


finicityCircle : Image
finicityCircle =
    image "finicity-circle.svg"


finicityCircleSelected : Image
finicityCircleSelected =
    image "finicity-circle-selected.svg"


stripeCircle : Image
stripeCircle =
    image "stripe-circle.svg"


stripeCircleSelected : Image
stripeCircleSelected =
    image "stripe-circle-selected.svg"


checkCircle : Image
checkCircle =
    image "check-circle.svg"


checkCircleSelected : Image
checkCircleSelected =
    image "check-circle-selected.svg"


lineUnselected : Image
lineUnselected =
    image "line-unselected.svg"


lineSelected : Image
lineSelected =
    image "line-selected.svg"


image : String -> Image
image filename =
    Image ("/assets/images/" ++ filename)



-- USING IMAGES


src : Image -> Attribute msg
src (Image url) =
    Attr.src url



-- USING GLYPHS


type Glyph
    = Glyph String


glyph : String -> List (Attribute msg) -> Html msg
glyph name more =
    i ([ class "fa", class name ] ++ more) []


circleCheckGlyph : List (Attribute msg) -> Html msg
circleCheckGlyph =
    glyph "fa-check-circle"


sackDollarGlyph : List (Attribute msg) -> Html msg
sackDollarGlyph =
    glyph "fa-sack-dollar"


minusCircleGlyph : List (Attribute msg) -> Html msg
minusCircleGlyph =
    glyph "fa-minus-circle"


linkGlyph : List (Attribute msg) -> Html msg
linkGlyph =
    glyph "fa-link"


coinsGlyph : List (Attribute msg) -> Html msg
coinsGlyph =
    glyph "fal fa-coins"


bellGlyph : List (Attribute msg) -> Html msg
bellGlyph =
    glyph "fas fa-bell"


userGlyph : List (Attribute msg) -> Html msg
userGlyph =
    glyph "fas fa-user"


universityGlyph : List (Attribute msg) -> Html msg
universityGlyph =
    glyph "fas fa-store-alt"


searchDollarGlyph : List (Attribute msg) -> Html msg
searchDollarGlyph =
    glyph "fas fa-search-dollar"
