module Home exposing (Model, Msg, init, update, view)

import Dict exposing (Dict)
import Html exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)

type Post
    = Post
        { name : String
        , postUrls : List String
        }

type alias Model =
    {}

initialModel : Model
initialModel =
    {}

init : Maybe String -> ( Model, Cmd Msg )
init selectedPost =
    ( { initialModel | selectedPostUrl = selectedPost }
    , Http.get
        { url = "https://centimentalcomics.com/index.json"
        , expect = Http.expectJson GotInitialModel modelDecoder
        }
    )

type Msg
    = GotInitialModel (Result Http.Error Model)

postsDecoder : Decoder (Dict String Post)
postsDecoder =
    Decode.keyValuePairs jsonPostDecoder
        |> Decode.map fromPairs

postDecoder : Decoder Post
postDecoder =
    Decode.succeed postFromJson
        |> required "name" string
        |> required "posts" postsDecoder

modelDecoder : Decoder Model
modelDecoder =
    Decode.map2
        (\posts root ->
            { posts = posts, root = root, selectedPostUrl = Nothing }
        )
        modelPostsDecoder
        postDecoder
