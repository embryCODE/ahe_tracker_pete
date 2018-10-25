module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Url.Builder as Url


-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { user : User, foods : List Food, counts : List Count }


type alias User =
    { first_name : String
    , last_name : String
    , email : String
    , password : String
    , id : String
    }


type alias Food =
    { name : String
    , category : String
    , id : String
    }


type alias Count =
    { count : String
    , user_id : String
    , food_id : String
    , id : String
    }


initialModel =
    { user =
        { first_name = "Mason"
        , last_name = "Embry"
        , email = "mason@example.com"
        , password = "password"
        , id = "2"
        }
    , foods =
        [ { name = "Vegetables", category = "Essential", id = "1" }
        , { name = "Fruits", category = "Essential", id = "2" }
        ]
    , counts =
        [ { id = "1"
          , user_id = "1"
          , food_id = "1"
          , count = "3.5"
          }
        , { id = "2"
          , user_id = "1"
          , food_id = "2"
          , count = "3.5"
          }
        , { id = "3"
          , user_id = "1"
          , food_id = "3"
          , count = "3.5"
          }
        ]
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.none
    )



-- UPDATE


type Msg
    = NewFood (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewFood result ->
            case result of
                Ok newName ->
                    ( model
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ h1 [] [ text "User" ]
            , p [] [ text model.user.first_name ]
            , p [] [ text model.user.last_name ]
            , p [] [ text model.user.email ]
            , p [] [ text model.user.password ]
            ]
        , div []
            [ h1 [] [ text "Food" ]
            , div []
                (List.map
                    (\food ->
                        div []
                            [ p [] [ text food.name ]
                            , p [] [ text food.category ]
                            ]
                    )
                    model.foods
                )
            ]
        , div []
            [ h1 [] [ text "Count" ]
            , div []
                (List.map
                    (\count ->
                        div []
                            [ p [] [ text count.user_id ]
                            , p [] [ text count.food_id ]
                            , p [] [ text count.id ]
                            , p [] [ text count.count ]
                            ]
                    )
                    model.counts
                )
            ]
        ]



-- HTTP


readFood : String -> Cmd Msg
readFood foodId =
    Http.send NewFood (Http.get (toReadFoodUrl foodId) foodDecoder)


toReadFoodUrl : String -> String
toReadFoodUrl foodId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "foods", foodId ]
        []


foodDecoder : Decode.Decoder String
foodDecoder =
    Decode.field "data" (Decode.field "name" Decode.string)
