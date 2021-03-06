module Database.Package.Encode exposing (..)

{-| Generated by elm-json-interop.
-}

import Database.Package as A
import Elm.Package.Encode
import Elm.Project.Encode
import Json.Encode as E
import Utils.Json.Encode_ as E_ exposing (Encoder)


package : Encoder A.Package
package =
    \v1 ->
        E.object
            [ ( "name"
              , Elm.Package.Encode.name v1.name
              )
            , ( "summary"
              , E.string v1.summary
              )
            , ( "exposed"
              , Elm.Project.Encode.exposed v1.exposed
              )
            ]
