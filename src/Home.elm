module Home exposing (Model, Msg, init, update, view)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class, href, src)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)

type Post
  = Post
    { image_url : String
    , image_alt : String
    , post_url : String
    , post_date : String
    , post_title : String
    , post_short_desc : String
    }

type PostPath
    = End

type alias Photo =
    { title : String
    , url : String
    }

urlPrefix : String
urlPrefix =
    "http://elm-in-action.com/"

viewRelatedPost : String -> Html Msg
viewRelatedPost name =
    let
        url =
            urlPrefix ++ "posts/" ++ name
    in
    div [ class "related-post", onClick (ClickPost name) ]
        [ img [ src url ] []
        ]

type Msg
    = ClickPost String
    | GotInitialModel (Result Http.Error Model)
    | ClickedPost PostPath

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickPost url ->
            ( { model | selectedPostUrl = Just url }, Cmd.none )

        GotInitialModel (Ok newModel) ->
            ( { newModel | selectedPostUrl = model.selectedPostUrl }, Cmd.none )

        GotInitialModel (Err _) ->
            ( model, Cmd.none )

        ClickedPost path ->
            ( { model | root = path }, Cmd.none )

viewSelectedPost : Photo -> Html Msg
viewSelectedPost photo =
    div
        [ class "selected-photo" ]
        [ h2 [] [ text photo.title ]
        , img [ src (urlPrefix ++ "photos/" ++ photo.url ++ "/full") ] []
        ]

type alias Model =
    { selectedPostUrl : Maybe String
    , posts : Dict String Post
    }

initialModel : Model
initialModel =
    { selectedPostUrl = Nothing
    , posts = Dict.empty
    , root = Post { name = "Loading...", postUrls = [] }
    }

init : Maybe String -> ( Model, Cmd Msg )
init selectedTitle =
    ( { initialModel | selectedPostUrl = selectedTitle }
    , Http.get
        { url = "https://centimentalcomics.com/index.json"
        , expect = Http.expectJson GotInitialModel modelDecoder
        }
    )

viewPost : PostPath -> Post -> Html Msg
viewPost path (Post post) =
    let
        postLabel =
            label [ onClick (ClickedPost path) ] [ text post.post_title ]
    in
    div [ class "post expanded" ]
        [ postLabel
        ]


view : Model -> Html Msg
view model =
    let
        selectedPhoto : Html Msg
        selectedPhoto =
            text ""
    in
    div [ class "content" ]
        [ div [ class "posts" ]
            [ viewPost End model.root
            ]
        , div [ class "selected-photo" ] [ selectedPhoto ]
        ]

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

finishPost : ( String, JsonPost ) -> ( String, Post )
finishPost ( url, json ) =
    (
      { url = url
      , title = json.title
      }
    )

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
