module Main exposing (..)

import Browser exposing (Document)
import Html exposing (text)

main =
    Browser.application
        { init = init
        }

init : Float -> Url -> Nav.Key -> ( Model, Cmd Msg )
init version url key =
    updateUrl url { page = NotFound, key = key, version = version }
