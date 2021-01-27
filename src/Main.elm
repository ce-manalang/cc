module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (text)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)

type alias Model =
    { page : Page
    }


type Page
    = NotFound


type Msg
    = ClickedLink Browser.UrlRequest


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [
        ]


main =
    Browser.application
        { init = init
        }


init : Float -> Url -> Nav.Key -> ( Model, Cmd Msg )
init version url key =
    updateUrl url { page = NotFound, key = key, version = version }


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Parser.parse parser url of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )
