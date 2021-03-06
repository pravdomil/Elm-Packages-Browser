module Elm.Project.Encode exposing (..)

{-| Generated by elm-json-interop.
-}

import Elm.Module.Encode
import Elm.Project as A
import Json.Encode as E
import Utils.Json.Encode_ as E_ exposing (Encoder)


exposed : Encoder A.Exposed
exposed =
    \v1 ->
        case v1 of
            A.ExposedList v2 ->
                E.object [ ( "_", E.int 0 ), ( "a", E.list Elm.Module.Encode.name v2 ) ]

            A.ExposedDict v2 ->
                E.object [ ( "_", E.int 1 ), ( "a", E.list (E_.tuple E.string (E.list Elm.Module.Encode.name)) v2 ) ]
