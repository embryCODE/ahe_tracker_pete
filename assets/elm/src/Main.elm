module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (..)
import Url.Builder as Url
import Debug


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
    , id : Int
    }


type alias Food =
    { name : String
    , category : String
    , id : Int
    }


type alias Count =
    { count : Float
    , user_id : Int
    , food_id : Int
    , id : Int
    }


type alias FoodCount =
    { name : String
    , count : String
    }



-- TODO: clean this up to just empty strings on init


initialModel =
    { user =
        { first_name = "Mason"
        , last_name = "Embry"
        , email = "mason@example.com"
        , id = 2
        }
    , foods =
        [ { name = "Vegetables", category = "Essential", id = 1 }
        , { name = "Fruits", category = "Essential", id = 2 }
        ]
    , counts =
        [ { id = 1
          , user_id = 1
          , food_id = 1
          , count = 3.5
          }
        ]
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.batch [ readUser "1", listFoods, listCounts ]
    )



-- UPDATE


type Msg
    = ReceiveUser (Result Http.Error User)
    | ReceiveFoods (Result Http.Error (List Food))
    | ReceiveCounts (Result Http.Error (List Count))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveUser result ->
            let
                _ =
                    Debug.log "Debug ReceiveUser" result
            in
                case result of
                    Ok user ->
                        ( { model | user = user }
                        , Cmd.none
                        )

                    Err _ ->
                        ( model
                        , Cmd.none
                        )

        ReceiveFoods result ->
            let
                _ =
                    Debug.log "Debug ReceiveFoods" result
            in
                case result of
                    Ok foods ->
                        ( { model | foods = foods }
                        , Cmd.none
                        )

                    Err _ ->
                        ( model
                        , Cmd.none
                        )

        ReceiveCounts result ->
            let
                _ =
                    Debug.log "Debug ReceiveCounts" result
            in
                case result of
                    Ok counts ->
                        ( { model | counts = counts }
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
            [ p [] [ text (model.user.first_name ++ " " ++ model.user.last_name) ]
            , p [] [ text model.user.email ]
            ]
        , div []
            [ div []
                (List.map
                    (\( categoryName, foodsInCategory ) ->
                        div []
                            [ p [] [ text categoryName ]
                            , ul []
                                (List.map
                                    (\food -> li [] [ text (food.name ++ " " ++ food.count) ])
                                    foodsInCategory
                                )
                            ]
                    )
                    (formatFoods model.foods model.counts)
                )
            ]
        ]


formatFoods : List Food -> List Count -> List ( String, List FoodCount )
formatFoods foodsFromApi countsFromApi =
    [ ( "Essential", [ FoodCount "Vegetables" "3", FoodCount "Fruits" "4" ] )
    , ( "Recommended", [ FoodCount "Whole Grains" "2", FoodCount "Dairy" "3", FoodCount "Nuts, Seeds, and Healthy Oils" "3" ] )
    , ( "Acceptable", [ FoodCount "Sweets" "3", FoodCount "Fried Foods" "1" ] )
    ]



-- HTTP
-- readUser


readUser : String -> Cmd Msg
readUser userId =
    Http.send ReceiveUser (Http.get (toReadUserUrl userId) userDecoder)


toReadUserUrl : String -> String
toReadUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", userId ]
        []


userDecoder : Decoder User
userDecoder =
    field "data"
        (map4 User
            (at [ "first_name" ] string)
            (at [ "last_name" ] string)
            (at [ "email" ] string)
            (at [ "id" ] int)
        )



-- listFoods


listFoods : Cmd Msg
listFoods =
    Http.send ReceiveFoods (Http.get (toReadFoodsUrl) foodListDecoder)


toReadFoodsUrl : String
toReadFoodsUrl =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "foods" ]
        []


foodListDecoder : Decoder (List Food)
foodListDecoder =
    field "data" (Decode.list foodDecoder)


foodDecoder : Decoder Food
foodDecoder =
    map3 Food
        (at [ "name" ] string)
        (at [ "category" ] string)
        (at [ "id" ] int)



-- listCounts


listCounts : Cmd Msg
listCounts =
    Http.send ReceiveCounts (Http.get (toReadCountsUrl) countListDecoder)


toReadCountsUrl : String
toReadCountsUrl =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "counts" ]
        []


countListDecoder : Decoder (List Count)
countListDecoder =
    field "data" (Decode.list countDecoder)


countDecoder : Decoder Count
countDecoder =
    map4 Count
        (at [ "count" ] float)
        (at [ "user_id" ] int)
        (at [ "food_id" ] int)
        (at [ "id" ] int)
