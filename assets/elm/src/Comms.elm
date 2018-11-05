module Comms exposing (..)

import Types exposing (..)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode
import Url.Builder as Url


-- updateFoodCount


updateFoodCount : ( Count, Float ) -> Cmd Msg
updateFoodCount args =
    Http.send CountUpdated (put (toUpdateFoodCountUrl args) (Http.jsonBody (updateCountBody args)))


put : String -> Http.Body -> Http.Request Count
put url body =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectJson (field "data" countDecoder)
        , timeout = Nothing
        , withCredentials = False
        }


updateCountBody : ( Count, Float ) -> Encode.Value
updateCountBody ( origCount, newCount ) =
    Encode.object
        [ ( "count"
          , Encode.object
                [ ( "count", Encode.float newCount )
                , ( "food_id", Encode.int origCount.food_id )
                , ( "user_id", Encode.int origCount.user_id )
                ]
          )
        ]


toUpdateFoodCountUrl : ( Count, Float ) -> String
toUpdateFoodCountUrl ( count, _ ) =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "counts", (String.fromInt count.id) ]
        []



-- readUser


readUser : Int -> Cmd Msg
readUser userId =
    Http.send ReceiveUser (Http.get (toReadUserUrl userId) userDecoder)


toReadUserUrl : Int -> String
toReadUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", (String.fromInt userId) ]
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
    map4 Food
        (at [ "name" ] string)
        (at [ "category" ] string)
        (at [ "id" ] int)
        (at [ "priority" ] int)



-- listCountsForUser


listCountsForUser : Int -> Cmd Msg
listCountsForUser userId =
    Http.send ReceiveCountsForUser (Http.get (toListCountsForUserUrl userId) countListDecoder)


toListCountsForUserUrl : Int -> String
toListCountsForUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", (String.fromInt userId), "counts" ]
        []


countListDecoder : Decoder (List Count)
countListDecoder =
    field "counts" (Decode.list countDecoder)


countDecoder : Decoder Count
countDecoder =
    map4 Count
        (at [ "count" ] float)
        (at [ "user_id" ] int)
        (at [ "food_id" ] int)
        (at [ "id" ] int)
