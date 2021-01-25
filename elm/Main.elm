module Main exposing (..)

import Browser exposing (Document)
import Html exposing (text)

type alias Model =
    { page : Page
    }


type Page
    = FoldersPage Folders.Model
    | GalleryPage Gallery.Model
    | NotFound


type Msg
    = ClickedLink Browser.UrlRequest


main =
    Browser.application
        { init = init
        }


init : Float -> Url -> Nav.Key -> ( Model, Cmd Msg )
init version url key =
    updateUrl url { page = NotFound, key = key, version = version }
