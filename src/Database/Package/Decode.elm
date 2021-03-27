module Database.Package.Decode exposing (..)

{-| Generated by elm-json-interop.
-}

import Database.Package as A
import Elm.Package.Decode
import Elm.Project.Decode
import Json.Decode as D exposing (Decoder)
import Utils.Json.Decode_ as D_


package : Decoder A.Package
package =
    D.map3
        (\v1 v2 v3 ->
            { name = v1
            , summary = v2
            , exposed = v3
            }
        )
        (D.field "name" Elm.Package.Decode.name)
        (D.field "summary" D.string)
        (D.field "exposed" Elm.Project.Decode.exposed)
