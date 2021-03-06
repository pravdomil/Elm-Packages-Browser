module Elm.Module.NameDict.Encode exposing (..)

{-| Generated by elm-json-interop.
-}

import Elm.Module.NameDict as A
import Json.Encode as E
import Utils.Json.Encode_ as E_ exposing (Encoder)


nameDict : Encoder v -> Encoder (A.NameDict v)
nameDict v =
    \(A.NameDict v1) -> E_.dict E.string v v1
