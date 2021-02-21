module Home exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Http

type alias Model =
    {}

initialModel : Model
initialModel =
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

modelDecoder : Decoder Model
modelDecoder =
    Decode.map2
        (\photos root ->
            { photos = photos, root = root, selectedPhotoUrl = Nothing }
        )
        modelPhotosDecoder
        folderDecoder
