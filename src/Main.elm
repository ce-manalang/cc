module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, a, footer, h1, li, nav, text, ul)
import Html.Lazy exposing (lazy)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)

type alias Model =
    { page : Page
    , key : Nav.Key
    , version : Float
    }


type Page
    = NotFound


type Route
    = Stories


view : Model -> Document Msg
view model =
    let
        content =
            case model.page of
                NotFound ->
                    text "Not Found"
    in
    { title = "centimentalcomics"
    , body =
        [ lazy viewHeader model.page
        , content
        , viewFooter
        ]
    }


viewHeader : Page -> Html Msg
viewHeader page =
    let
        logo =
            h1 [] [ text "centimentalcomics" ]

        links =
            ul []
                -- [ navLink Home { url = "/", caption = "Home" }
                -- , navLink About { url = "/about", caption = "About" }
                -- ]

        -- navLink : Route -> { url : String, caption : String } -> Html msg
        -- navLink route { url, caption } =
        --     li
        --        [ classList
        --            [ ( "active"
        --              , isActive { link = route, page = page }
        --              )
        --            ]
        --        ]
        --        [ a [ href url ] [ text caption ] ]
    in
    -- nav [] [ logo, links ]
    nav [] [ logo ]


viewFooter : Html msg
viewFooter =
    footer []
        [ text "One is never alone with a rubber duck. -Douglas Adams" ]


type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        ChangedUrl url ->
            updateUrl url model


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [
        ]


main : Program Float Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : Float -> Url -> Nav.Key -> ( Model, Cmd Msg )
init version url key =
    updateUrl url { page = NotFound, key = key, version = version }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        _ ->
            Sub.none


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Parser.parse parser url of
        Just _ ->
            ( { model | page = NotFound }, Cmd.none )

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )
