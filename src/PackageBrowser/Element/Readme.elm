module PackageBrowser.Element.Readme exposing (..)

import Database.Package.Readme as Readme
import Database.Package.Readme.Decode
import Dict exposing (Dict)
import Element
import Element.Events exposing (onClick)
import Elm.Docs
import Elm.Module
import Elm.Module.NameDict as ModuleNameDict
import Elm.Package
import Elm.Package.NameDict as PackageNameDict
import Elm.Type
import Http
import Markdown.Renderer
import PackageBrowser.Element.Readme.Section as Section
import PackageBrowser.Router as Router
import PackageBrowser.Strings as Strings
import PackageBrowser.Ui exposing (..)
import PackageBrowser.Ui.Markdown as Markdown


type alias Context a b =
    { a
        | router :
            { b
                | view : Router.View
            }
    }



--


type alias Model =
    { readmes : PackageNameDict.NameDict (Result Error Readme.Readme)
    , expandedSections : PackageNameDict.NameDict (ModuleNameDict.NameDict (Dict String ()))
    }


type Error
    = Loading
    | HttpError Http.Error


init : ( Model, Cmd Msg )
init =
    ( { readmes = PackageNameDict.empty
      , expandedSections = PackageNameDict.empty
      }
    , Cmd.none
    )


getPackage : Elm.Package.Name -> Cmd Msg
getPackage a =
    Http.get
        { url = "db/" ++ (a |> Elm.Package.toString |> String.replace "/" " ") ++ ".json"
        , expect = Http.expectJson (GotReadme a) Database.Package.Readme.Decode.readme
        }



--


type Msg
    = ViewChanged
    | GotReadme Elm.Package.Name (Result Http.Error Readme.Readme)
    | Reveal Elm.Package.Name
    | ToggleSection Elm.Package.Name Elm.Module.Name String


update : Context a b -> Msg -> Model -> ( Model, Cmd Msg )
update ctx msg model =
    case msg of
        ViewChanged ->
            case ctx.router.view |> Router.viewToPackageName of
                Just b ->
                    case model.readmes |> PackageNameDict.get b of
                        Just _ ->
                            ( model
                            , Cmd.none
                            )

                        Nothing ->
                            ( { model | readmes = model.readmes |> PackageNameDict.insert b (Err Loading) }
                            , getPackage b
                            )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        Reveal _ ->
            ( model
            , Cmd.none
            )

        GotReadme a b ->
            ( { model | readmes = model.readmes |> PackageNameDict.insert a (b |> Result.mapError HttpError) }
            , Cmd.none
            )

        ToggleSection a b c ->
            ( { model
                | expandedSections =
                    model.expandedSections
                        |> PackageNameDict.update a
                            (\v ->
                                v
                                    |> Maybe.withDefault ModuleNameDict.empty
                                    |> ModuleNameDict.update b
                                        (\vv ->
                                            vv
                                                |> Maybe.withDefault Dict.empty
                                                |> Dict.update c
                                                    (\vvv ->
                                                        if vvv == Nothing then
                                                            Just ()

                                                        else
                                                            Nothing
                                                    )
                                                |> Just
                                        )
                                    |> Just
                            )
              }
            , Cmd.none
            )



--


view : Router.View -> Model -> Element Msg
view view_ model =
    column [ width fill, height fill ]
        (case view_ of
            Router.DefaultView ->
                []

            Router.PackageView b ->
                [ viewPackageHeader b
                , viewPackageReadme (PackageNameDict.get b model.readmes)
                ]

            Router.ModuleView b c ->
                let
                    d : Dict String ()
                    d =
                        model.expandedSections
                            |> PackageNameDict.get b
                            |> Maybe.andThen (ModuleNameDict.get c)
                            |> Maybe.withDefault Dict.empty
                in
                [ viewPackageHeader b
                , viewModuleHeader b c
                , viewModuleReadme b c d (PackageNameDict.get b model.readmes)
                ]
        )


viewReadme : (a -> Element msg) -> Maybe (Result Error a) -> Element msg
viewReadme fn a =
    column
        [ width fill
        , height fill
        , spacing 2
        , paddingEach 1 1 1 8
        , Element.scrollbars
        ]
        [ case a of
            Just b ->
                case b of
                    Ok c ->
                        fn c

                    Err c ->
                        case c of
                            Loading ->
                                status []
                                    [ text Strings.loading
                                    ]

                            HttpError d ->
                                status []
                                    [ text (Strings.httpError d)
                                    ]

            Nothing ->
                status []
                    [ text Strings.packageNotFound
                    ]
        ]


viewPackageHeader : Elm.Package.Name -> Element Msg
viewPackageHeader a =
    row
        [ width fill
        , spacing 1
        , paddingXY 1 0.75
        , borderColor gray3
        , borderWidthEach 0 0 0 1
        ]
        [ h4 []
            [ link [ fontColor gray9, onClick (Reveal a) ]
                { label = text (Elm.Package.toString a)
                , url = Router.PackageView a |> Router.viewToUrl
                }
            ]
        , newTabLink []
            { label = text Strings.officialDocs
            , url = "https://package.elm-lang.org/packages/" ++ Elm.Package.toString a ++ "/latest/"
            }
        , newTabLink []
            { label = text Strings.source
            , url = "https://github.com/" ++ Elm.Package.toString a
            }
        ]


viewModuleHeader : Elm.Package.Name -> Elm.Module.Name -> Element Msg
viewModuleHeader a b =
    row
        [ width fill
        , spacing 1
        , paddingXY 1 0.75
        , borderColor gray3
        , borderWidthEach 0 0 0 1
        ]
        [ h5 []
            [ link [ fontColor gray9, onClick (Reveal a) ]
                { label = text (Elm.Module.toString b)
                , url = Router.ModuleView a b |> Router.viewToUrl
                }
            ]
        , newTabLink []
            { label = text Strings.officialDocs
            , url = "https://package.elm-lang.org/packages/" ++ Elm.Package.toString a ++ "/latest/" ++ (Elm.Module.toString b |> String.replace "." "-")
            }
        , newTabLink []
            { label = text Strings.source
            , url = "https://github.com/" ++ Elm.Package.toString a ++ "/blob/master/src/" ++ (Elm.Module.toString b |> String.replace "." "/") ++ ".elm"
            }
        ]


viewPackageReadme : Maybe (Result Error Readme.Readme) -> Element msg
viewPackageReadme a =
    let
        view_ : Readme.Readme -> Element msg
        view_ b =
            Markdown.view [ padding 1.5 ] b.readme
    in
    viewReadme view_ a



--


viewModuleReadme : Elm.Package.Name -> Elm.Module.Name -> Dict String () -> Maybe (Result Error Readme.Readme) -> Element Msg
viewModuleReadme a b expanded c =
    let
        view_ : Readme.Readme -> Element Msg
        view_ d =
            case d.modules |> ModuleNameDict.get b of
                Just e ->
                    let
                        defaultTitle : String
                        defaultTitle =
                            Elm.Module.toString b
                                |> String.split "."
                                |> List.reverse
                                |> List.head
                                |> Maybe.withDefault ""
                    in
                    case e.readme |> Section.fromMarkdown defaultTitle of
                        Ok f ->
                            column [ width fill, spacing 1 ]
                                (f
                                    |> List.map
                                        (\v ->
                                            column [ width fill ]
                                                [ buttonLink [ fontColor gray6, paddingXY 0 0.25 ]
                                                    { label = text v.name
                                                    , onPress = Just (ToggleSection a b v.name)
                                                    }
                                                , column [ width fill, paddingXY 1.5 0 ]
                                                    [ viewItems e (Dict.member v.name expanded) v.items
                                                    ]
                                                ]
                                        )
                                )

                        Err _ ->
                            status []
                                [ text Strings.readmeIsNotAvailable
                                ]

                Nothing ->
                    status []
                        [ text Strings.moduleNotFound
                        ]
    in
    viewReadme view_ c


viewItems : Readme.ModuleReadme -> Bool -> List Section.Item -> Element msg
viewItems module_ expand a =
    let
        viewItem : Section.Item -> Element msg
        viewItem b =
            case b of
                Section.Markdown c ->
                    column [ width fill, spacing 2, paddingEach 1.5 1.5 0.25 1.5 ]
                        [ column
                            [ width fill
                            , padding 1
                            , spacing 1
                            , backgroundColor gray1
                            , borderRounded 0.25
                            , fontSize 0.9375
                            ]
                            (c
                                |> Markdown.Renderer.render Markdown.renderer
                                |> Result.withDefault
                                    [ status []
                                        [ text Strings.readmeIsNotAvailable
                                        ]
                                    ]
                            )
                        ]

                Section.Member c ->
                    c
                        |> toMember
                        |> Maybe.map (viewMember expand)
                        |> Maybe.withDefault none

        toMember : String -> Maybe { name : String, type_ : String, comment : String }
        toMember b =
            Nothing
                |> onNothing (\_ -> module_.unions |> Dict.get b |> Maybe.map viewUnion)
                |> onNothing (\_ -> module_.aliases |> Dict.get b |> Maybe.map viewAlias)
                |> onNothing (\_ -> module_.values |> Dict.get b |> Maybe.map viewValue)
                |> onNothing (\_ -> module_.binops |> Dict.get b |> Maybe.map viewBinop)
    in
    column [ width fill ]
        (a
            |> (\v ->
                    if expand then
                        v

                    else
                        v
                            |> List.filter
                                (\vv ->
                                    case vv of
                                        Section.Member _ ->
                                            True

                                        _ ->
                                            False
                                )
               )
            |> List.map viewItem
        )


viewMember : Bool -> { name : String, type_ : String, comment : String } -> Element msg
viewMember expand a =
    column [ width fill ]
        [ row [ width fill ]
            [ text a.name
            , el [ fontColor gray5 ] (text a.type_)
            ]
        , if expand then
            column [ width fill, spacing 2, paddingEach 1.5 1.5 0.25 1.5 ]
                [ Markdown.view
                    [ padding 1
                    , backgroundColor gray1
                    , borderRounded 0.5
                    , fontSize 0.9375
                    ]
                    a.comment
                ]

          else
            none
        ]



--


viewUnion : Elm.Docs.Union -> { name : String, type_ : String, comment : String }
viewUnion a =
    let
        type_ : String
        type_ =
            (if a.args == [] then
                []

             else
                "" :: a.args
            )
                ++ (if a.tags == [] then
                        []

                    else
                        ""
                            :: "="
                            :: [ a.tags
                                    |> List.map
                                        (\( vv, vvv ) ->
                                            vv
                                                :: (vvv
                                                        |> List.map typeToString
                                                        |> List.map
                                                            (\v ->
                                                                if List.length v > 1 then
                                                                    "(" ++ String.join " " v ++ ")"

                                                                else
                                                                    v |> String.join " "
                                                            )
                                                   )
                                                |> String.join " "
                                        )
                                    |> String.join " | "
                               ]
                   )
                |> String.join " "
    in
    { name = a.name
    , type_ = type_
    , comment = a.comment
    }


viewAlias : Elm.Docs.Alias -> { name : String, type_ : String, comment : String }
viewAlias a =
    { name = a.name
    , type_ = "" :: a.args ++ [ "=" ] ++ typeToString a.tipe |> String.join " "
    , comment = a.comment
    }


viewValue : Elm.Docs.Value -> { name : String, type_ : String, comment : String }
viewValue a =
    { name = a.name
    , type_ = "" :: ":" :: typeToString a.tipe |> String.join " "
    , comment = a.comment
    }


viewBinop : Elm.Docs.Binop -> { name : String, type_ : String, comment : String }
viewBinop a =
    { name = a.name
    , type_ = "" :: ":" :: typeToString a.tipe |> String.join " "
    , comment = a.comment
    }


typeToString : Elm.Type.Type -> List String
typeToString a =
    case a of
        Elm.Type.Var b ->
            [ b
            ]

        Elm.Type.Lambda b c ->
            [ b |> typeToString |> String.join " "
            , "->"
            , c |> typeToString |> String.join " "
            ]

        Elm.Type.Tuple b ->
            if b == [] then
                [ "()"
                ]

            else
                [ "("
                , b |> List.map (typeToString >> String.join " ") |> String.join ", "
                , ")"
                ]
                    |> String.join " "
                    |> List.singleton

        Elm.Type.Type b c ->
            let
                name : String
                name =
                    b |> String.split "." |> List.reverse |> List.head |> Maybe.withDefault ""
            in
            if c == [] then
                [ name
                ]

            else
                [ name
                , c
                    |> List.map typeToString
                    |> List.map
                        (\v ->
                            if List.length v > 1 then
                                "(" ++ String.join " " v ++ ")"

                            else
                                v |> String.join " "
                        )
                    |> String.join " "
                ]

        Elm.Type.Record b c ->
            let
                open : String
                open =
                    case c of
                        Just d ->
                            "{ " ++ d ++ " |"

                        Nothing ->
                            "{"
            in
            [ open
            , b
                |> List.map (\( v, vv ) -> v :: ":" :: typeToString vv |> String.join " ")
                |> String.join ", "
            , "}"
            ]
                |> String.join " "
                |> List.singleton



--


onNothing : (() -> Maybe a) -> Maybe a -> Maybe a
onNothing fn b =
    case b of
        Just c ->
            Just c

        Nothing ->
            fn ()
