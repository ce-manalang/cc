module Home exposing (Model, Msg, init, update, view)

import Dict exposing (Dict)
import Http

type alias Post =
    { image_url : String
    , image_alt : String
    , post_url : String
    , post_date : String
    , post_title : String
    , post_short_desc : String
    }

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

modelDecoder : Decoder Model
modelDecoder =
    Decode.map2
        (\posts root ->
            { posts = posts, root = root, selectedPostUrl = Nothing }
        )
        modelPostsDecoder
        postDecoder
