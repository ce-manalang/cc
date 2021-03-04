module Home exposing (Model, Msg, init, update, view)

import Dict exposing (Dict)
import Html exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)

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

type alias JsonPost =
    { title : String
    , size : Int
    , relatedUrls : List String
    }

finishPost : ( String, JsonPost ) -> ( String, Post )
finishPost ( url, json ) =
    ( url
    , { url = url
      }
    )

fromPairs : List ( String, JsonPost ) -> Dict String Post
fromPairs pairs =
    pairs
        |> List.map finishPost
        |> Dict.fromList

postsDecoder : Decoder (Dict String Post)
postsDecoder =
    Decode.keyValuePairs jsonPostDecoder
        |> Decode.map fromPairs

jsonPostDecoder : Decoder JsonPost
jsonPostDecoder =
    Decode.succeed JsonPost
        |> required "title" string

postDecoder : Decoder Post
postDecoder =
    Decode.succeed postFromJson
        |> required "name" string
        |> required "posts" postsDecoder

postFromJson : String -> Dict String Post -> List Post -> Post
postFromJson name posts =
    Post
        { name = name
        , postUrls = Dict.keys posts
        }

modelPostsDecoder : Decoder (Dict String Post)
modelPostsDecoder =
    Decode.succeed modelPostsFromJson
        |> required "posts" postsDecoder

modelDecoder : Decoder Model
modelDecoder =
    Decode.map2
        (\posts root ->
            { posts = posts, root = root, selectedPostUrl = Nothing }
        )
        modelPostsDecoder
        postDecoder
