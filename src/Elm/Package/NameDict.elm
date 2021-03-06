module Elm.Package.NameDict exposing (..)

import Dict
import Elm.Package


type NameDict v
    = NameDict (Dict.Dict String v)


fromList : List ( Elm.Package.Name, v ) -> NameDict v
fromList a =
    a
        |> List.map (Tuple.mapFirst Elm.Package.toString)
        |> Dict.fromList
        |> NameDict


empty : NameDict v
empty =
    fromList []


toList : NameDict v -> List ( Elm.Package.Name, v )
toList (NameDict a) =
    a
        |> Dict.toList
        |> List.filterMap (\( k, v ) -> Elm.Package.fromString k |> Maybe.map (\vv -> ( vv, v )))


member : Elm.Package.Name -> NameDict v -> Bool
member k (NameDict a) =
    a |> Dict.member (Elm.Package.toString k)


get : Elm.Package.Name -> NameDict v -> Maybe v
get k (NameDict a) =
    a |> Dict.get (Elm.Package.toString k)


insert : Elm.Package.Name -> v -> NameDict v -> NameDict v
insert k v (NameDict a) =
    a |> Dict.insert (Elm.Package.toString k) v |> NameDict


update : Elm.Package.Name -> (Maybe v -> Maybe v) -> NameDict v -> NameDict v
update k fn (NameDict a) =
    a |> Dict.update (Elm.Package.toString k) fn |> NameDict
