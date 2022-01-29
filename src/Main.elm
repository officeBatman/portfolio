module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Browser
import Browser.Navigation as Nav
import Url
import Url.Parser


type alias Flags = ()


type Page
    = Home { field: Field }
    | Blog


type alias Model =
    { key: Nav.Key
    , url: Url.Url
    , page: Page
    }


type Field
    = Software
    | Web
    | MachineLearning


type Msg
    = SetField Field
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest


fieldToString : Field -> String
fieldToString field =
    case field of
        Software -> "software"
        Web -> "web"
        MachineLearning -> "machine learning"


type Route
    = HomeRoute
    | BlogRoute


routeParser : Url.Parser.Parser (Route -> a) a
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.s "index.html" |> Url.Parser.map HomeRoute
        , Url.Parser.top |> Url.Parser.map HomeRoute
        , Url.Parser.s "blog" |> Url.Parser.map BlogRoute
        ]


urlToRoute : Url.Url -> Maybe Route
urlToRoute = Url.Parser.parse routeParser


changeRoute : Maybe Route -> Model -> (Model, Cmd Msg)
changeRoute route model =
    case route of
        Nothing -> (model, Cmd.none) |> Debug.log "No route"

        Just HomeRoute ->
            ({ model | page = Home { field = Software } }
            , Cmd.none
            ) |> Debug.log "Home route"

        Just BlogRoute ->
            ({ model | page = Blog }, Cmd.none) |> Debug.log "Blog route"


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


init : Flags -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init () url key =
    ( Model key url <| Home { field = Software }
    , Cmd.none
    )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetField field ->
            ({ model | page = Home { field = field } }, Cmd.none) 

        UrlChanged url ->
            changeRoute (urlToRoute url) model

        LinkClicked request ->
            case request of
                Browser.Internal url ->
                    (model, Nav.pushUrl model.key (Url.toString url))

                Browser.External href ->
                    (model, Nav.load href)


view : Model -> Browser.Document Msg
view model =
    { title = "Yonatan Reicher | Math & Computer Science"
    , body =
        case model.page of
            Home { field } -> 
                [ viewHeadings field
                , viewProjects
                ]

            Blog ->
                [ viewBlog ]
    }


viewHeadings : Field -> Html Msg
viewHeadings field =
    div [ class "headings" ]
        [ h1 []
            [ text "Hello, I'm "
            , span [ class "name" ] [ text "Yonatan" ]
            , text "."
            ]
        , h1 []
            [ span [] [ text "I'm a " ]
            , div [ class "field" ]
                [ span [ class "highlight" ] [ text (fieldToString field) ]
                , div [ class "field-options-panel" ]
                    [ div
                        [ class "field-option"
                        , onClick (SetField Software) ]
                        [ text (fieldToString Software) ]
                    , div
                        [ class "field-option"
                        , onClick (SetField Web) ]
                        [ text (fieldToString Web) ]
                    , div
                        [ class "field-option"
                        , onClick (SetField MachineLearning) ]
                        [ text (fieldToString MachineLearning) ]
                    ]
                ]
            , span [] [ text " engineer." ]
            ]
        ]


viewProjects : Html Msg
viewProjects =
    div [ class "projects" ]
        [ h1 [] [ text "Projects" ]
        , ul []
            [ li []
                [ a [ href "/blog" ]
                    [ text "Articles" ]
                ]
            , li []
                [ a [ href "https://gitlab.com/affogato/affogato" ]
                    [ text "Affogato" ]
                ]
            ]
        ]


viewBlog : Html Msg
viewBlog = 
    text "blog lol"


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

