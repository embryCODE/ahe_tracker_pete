module Count exposing (Count, listCountsForUser, updateFoodCount)

import Http
import Json.Decode as D
import Json.Encode as E
import Url.Builder as Url


type alias Count =
    { count : Float
    , user_id : Int
    , food_id : Int
    , id : Int
    }



-- updateFoodCount


updateFoodCount : ( Count, Float ) -> Http.Request Count
updateFoodCount args =
    put (toUpdateFoodCountUrl args) (Http.jsonBody (updateCountBody args))


put : String -> Http.Body -> Http.Request Count
put url body =
    Http.request
        { method = "PUT"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectJson (D.field "data" decode)
        , timeout = Nothing
        , withCredentials = False
        }


updateCountBody : ( Count, Float ) -> E.Value
updateCountBody ( origCount, newCount ) =
    E.object
        [ ( "count"
          , E.object
                [ ( "count", E.float newCount )
                , ( "food_id", E.int origCount.food_id )
                , ( "user_id", E.int origCount.user_id )
                ]
          )
        ]


toUpdateFoodCountUrl : ( Count, Float ) -> String
toUpdateFoodCountUrl ( count, _ ) =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "counts", (String.fromInt count.id) ]
        []



-- listCountsForUser


listCountsForUser : Int -> Http.Request (List Count)
listCountsForUser userId =
    Http.get (toListCountsForUserUrl userId) (D.field "counts" (D.list decode))


toListCountsForUserUrl : Int -> String
toListCountsForUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", (String.fromInt userId), "counts" ]
        []


decode : D.Decoder Count
decode =
    D.map4 Count
        (D.at [ "count" ] D.float)
        (D.at [ "user_id" ] D.int)
        (D.at [ "food_id" ] D.int)
        (D.at [ "id" ] D.int)
