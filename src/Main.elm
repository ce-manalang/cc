module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (text)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)

type alias Model =
    { page : Page
    , key : Nav.Key
    , version : Float
    }


type Page
    = NotFound


type Route
    = Stories


type Msg
    = ClickedLink Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [
        ]


main : Program Float Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        }


init : Float -> Url -> Nav.Key -> ( Model, Cmd Msg )
init version url key =
    updateUrl url { page = NotFound, key = key, version = version }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        _ ->
            Sub.none


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Parser.parse parser url of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )
