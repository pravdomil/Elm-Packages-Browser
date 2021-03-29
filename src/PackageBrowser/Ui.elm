module PackageBrowser.Ui exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html
import Html.Attributes


white =
    rgb255 255 255 255


gray100 =
    rgb255 248 249 250


gray200 =
    rgb255 233 236 239


gray300 =
    rgb255 222 226 230


gray400 =
    rgb255 206 212 218


gray500 =
    rgb255 173 181 189


gray600 =
    rgb255 108 117 125


gray700 =
    rgb255 73 80 87


gray800 =
    rgb255 52 58 64


gray900 =
    rgb255 33 37 41


black =
    rgb255 0 0 0



--


blue =
    rgb255 13 110 253


indigo =
    rgb255 102 16 242


purple =
    rgb255 111 66 193


pink =
    rgb255 214 51 132


red =
    rgb255 220 53 69


orange =
    rgb255 253 126 20


yellow =
    rgb255 255 193 7


green =
    rgb255 25 135 84


teal =
    rgb255 32 201 151


cyan =
    rgb255 13 202 240



--


primary =
    blue


secondary =
    gray600


success =
    green


info =
    cyan


warning =
    yellow


danger =
    red


light =
    gray100


dark =
    gray900



--


defaultTextColor =
    Font.color gray900


mutedTextColor =
    Font.color gray600


defaultBackgroundColor =
    Background.color gray100


defaultBorderColor =
    Border.color gray300


inputBorderColor =
    Border.color gray400


shadow =
    Border.shadow
        { offset = ( 0, 16 )
        , size = 0
        , blur = 48
        , color = black |> toRgb |> (\v -> { v | alpha = 0.2 }) |> fromRgb
        }


fontSansSerif =
    [ Font.typeface "system-ui"
    , Font.typeface "-apple-system"
    , Font.typeface "Segoe UI"
    , Font.typeface "Roboto"
    , Font.typeface "Helvetica Neue"
    , Font.typeface "Arial"
    , Font.typeface "Noto Sans"
    , Font.typeface "Liberation Sans"
    , Font.sansSerif
    , Font.typeface "Apple Color Emoji"
    , Font.typeface "Segoe UI Emoji"
    , Font.typeface "Segoe UI Symbol"
    , Font.typeface "Noto Color Emoji"
    ]


fontMonospace =
    [ Font.typeface "SFMono-Regular"
    , Font.typeface "Menlo"
    , Font.typeface "Monaco"
    , Font.typeface "Consolas"
    , Font.typeface "Liberation Mono"
    , Font.typeface "Courier New"
    , Font.monospace
    ]



--


rootStyle a =
    defaultBackgroundColor
        :: defaultTextColor
        :: Font.size 16
        :: Font.family fontSansSerif
        :: a


inputStyle a =
    padding 8
        :: spacing 8
        :: Background.color white
        :: inputBorderColor
        :: border
        :: Border.rounded 4
        :: a



--


type alias Element msg =
    Element.Element msg



--


row a =
    Element.row
        (spacing 16
            :: width fill
            :: a
        )


column a =
    Element.column
        (spacing 16
            :: width fill
            :: a
        )


section a =
    Element.column
        (spacing 16
            :: width fill
            :: a
        )



--


h1 a =
    p (Region.heading 1 :: Font.size 40 :: a)


h2 a =
    p (Region.heading 2 :: Font.size 32 :: a)


h3 a =
    p (Region.heading 3 :: Font.size 28 :: a)


h4 a =
    p (Region.heading 4 :: Font.size 24 :: a)


h5 a =
    p (Region.heading 5 :: Font.size 20 :: a)


h6 a =
    p (Region.heading 6 :: Font.size 16 :: a)


p a =
    paragraph (spacing 8 :: a)


status a =
    p (Element.padding 16 :: Font.center :: mutedTextColor :: a)



--


none =
    Element.none


noneAttribute =
    Element.htmlAttribute (Html.Attributes.classList [])


text =
    Element.text


el =
    Element.el


br =
    html (Html.br [] [])


image =
    Element.image


link a =
    Element.link (Font.color primary :: a)


newTabLink a =
    Element.newTabLink (Font.color primary :: a)


buttonLink a =
    Input.button
        (Font.color primary
            :: Border.rounded 2
            :: a
        )



--


id a =
    Element.htmlAttribute (Html.Attributes.id a)



--


border =
    Border.width 1


borderLeft =
    Border.widthEach { edges | left = 1 }


borderRight =
    Border.widthEach { edges | right = 1 }


borderTop =
    Border.widthEach { edges | top = 1 }


borderBottom =
    Border.widthEach { edges | bottom = 1 }


edges =
    { left = 0, right = 0, top = 0, bottom = 0 }



--


searchInput a =
    Input.search (inputStyle a)


placeholder a =
    Input.placeholder (Font.size 14 :: a)


labelHidden =
    Input.labelHidden


labelAbove a =
    Input.labelAbove (Font.size 12 :: a)
