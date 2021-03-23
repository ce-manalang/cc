module Home exposing (Model, Msg, init, update, view)

import Dict exposing (Dict)
import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)

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

initialModel : Model
initialModel =
    { selectedPostUrl = Nothing
    , posts = Dict.empty
    , root = Folder { name = "Loading...", postUrls = [] }
    }

init : Maybe String -> ( Model, Cmd Msg )
init selectedTitle =
    ( { initialModel | selectedPostUrl = selectedTitle }
    , Http.get
        { url = "https://centimentalcomics.com/index.json"
        , expect = Http.expectJson GotInitialModel modelDecoder
        }
    )

type alias JsonPost =
    { title : String
    }

postsDecoder : Decoder (Dict String Post)
postsDecoder =
    Decode.keyValuePairs jsonPostDecoder
        |> Decode.map fromPairs

jsonPostDecoder : Decoder JsonPost
jsonPostDecoder =
    Decode.succeed JsonPost
        |> required "title" string

fromPairs : List ( String, JsonPost ) -> Dict String Post
fromPairs pairs =
    pairs
        |> List.map finishPost
        |> Dict.fromList

postDecoder : Decoder Post
postDecoder =
    Decode.succeed postFromJson
        |> required "title" string

postFromJson : String -> Dict String Post -> List Post -> Post
postFromJson title posts =
    Post
        { title = title
        }

modelPostsDecoder : Decoder (Dict String Post)
modelPostsDecoder =
    Decode.succeed modelPostsFromJson
        |> required "posts" postsDecoder

modelPostsFromJson : Dict String Post -> List (Dict String Post) -> Dict String Post
modelPostsFromJson posts =
    List.foldl Dict.union posts

modelDecoder : Decoder Model
modelDecoder =
    Decode.map2
        (\posts root ->
            { posts = posts, root = root, selectedPostUrl = Nothing }
        )
        modelPostsDecoder
        postDecoder
