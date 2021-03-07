module Home exposing (Model, Msg, init, update, view)

type Msg
    = GotInitialModel (Result Http.Error Model)

init : Maybe String -> ( Model, Cmd Msg )
init selectedTitle =
    ( { initialModel | selectedPostUrl = selectedTitle }
    , Http.get
        { url = "https://centimentalcomics.com/index.json"
        , expect = Http.expectJson GotInitialModel modelDecoder
        }
    )
