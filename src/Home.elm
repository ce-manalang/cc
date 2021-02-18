module Home exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, href, src)

type alias Model =
    {}

init : Maybe String -> ( Model, Cmd Msg )
init selectedFilename =
    ( { initialModel | selectedPhotoUrl = selectedFilename }
    , Http.get
        { url = "http://elm-in-action.com/folders/list"
        , expect = Http.expectJson GotInitialModel modelDecoder
        }
    )

type Msg
    = GotInitialModel (Result Http.Error Model)
