module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (text)
import Url exposing (Url)

type alias Model =
    { page : Page
    }


type Page
    = NotFound


type Msg
    = ClickedLink Browser.UrlRequest


main =
    Browser.application
        { init = init
        }


init : Float -> Url -> Nav.Key -> ( Model, Cmd Msg )
init version url key =
    updateUrl url { page = NotFound, key = key, version = version }
