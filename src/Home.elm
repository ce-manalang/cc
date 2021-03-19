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

postsDecoder : Decoder (Dict String Post)
postsDecoder =
    Decode.keyValuePairs jsonPostDecoder
        |> Decode.map fromPairs

postDecoder : Decoder Post
postDecoder =
    Decode.succeed postFromJson
        |> required "title" string

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
