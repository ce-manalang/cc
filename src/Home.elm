module Home exposing (Model, Msg, init, update, view)

import Dict exposing (Dict)

type Msg
    = GotInitialModel (Result Http.Error Model)

type alias Model =
    { selectedPostUrl : Maybe String
    , posts : Dict String Post
    }

init : Maybe String -> ( Model, Cmd Msg )
init selectedTitle =
    ( { initialModel | selectedPostUrl = selectedTitle }
    , Http.get
        { url = "https://centimentalcomics.com/index.json"
        , expect = Http.expectJson GotInitialModel modelDecoder
        }
    )
