module Database.ModuleGroup exposing (..)

import Database.Package
import Elm.Module as Module
import Elm.Module.NameDict as NameDict
import Elm.Package as Package
import Regex


type alias ModuleGroup =
    { name : Module.Name
    , modules : List ( Package.Name, Module.Name )
    }


type alias ModuleGroupDict =
    NameDict.NameDict (List ( Package.Name, Module.Name ))


fromPackages : List Database.Package.Package -> List ModuleGroup
fromPackages a =
    let
        fold : ( Package.Name, Module.Name ) -> ModuleGroupDict -> ModuleGroupDict
        fold ( package, module_ ) acc =
            acc
                |> NameDict.update
                    (parentModule module_)
                    (\v ->
                        v |> Maybe.withDefault [] |> (::) ( package, module_ ) |> Just
                    )
    in
    a
        |> List.concatMap
            (\v ->
                v.exposed |> Database.Package.exposedToList |> List.map (Tuple.pair v.name)
            )
        |> List.foldl fold NameDict.empty
        |> NameDict.toList
        |> List.map (\( v, vv ) -> { name = v, modules = List.reverse vv })
        |> List.sortBy (.name >> Module.toString >> String.toLower)


parentModule : Module.Name -> Module.Name
parentModule a =
    let
        elmReview : Regex.Regex
        elmReview =
            Regex.fromString "^No[A-Z]" |> Maybe.withDefault Regex.never
    in
    if a |> Module.toString |> Regex.contains elmReview then
        Module.fromString "Review"
            |> Maybe.withDefault a

    else if a |> Module.toString |> String.startsWith "Vector" then
        Module.fromString "Vector"
            |> Maybe.withDefault a

    else
        a
            |> Module.toString
            |> String.split "."
            |> List.head
            |> Maybe.andThen Module.fromString
            |> Maybe.withDefault a