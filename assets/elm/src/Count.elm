module Count exposing (Count, listCountsForUserRequest, updateCountRequest, encode, decode)

import Http
import Json.Decode as D
import Json.Encode as E
import Url.Builder as Url


type alias Count =
    { id : Int
    , user_id : Int
    , food_id : Int
    , count : Float
    }



-- UPDATE COUNT


updateCountRequest : ( Count, Float ) -> Http.Request Count
updateCountRequest args =
    put (toUpdateFoodCountUrl args) (Http.jsonBody (encodeForApi args))


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


toUpdateFoodCountUrl : ( Count, Float ) -> String
toUpdateFoodCountUrl ( count, _ ) =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "counts", (String.fromInt count.id) ]
        []



-- LIST COUNTS FOR USER


listCountsForUserRequest : Int -> Http.Request (List Count)
listCountsForUserRequest userId =
    Http.get (toListCountsForUserUrl userId) (D.field "counts" (D.list decode))


toListCountsForUserUrl : Int -> String
toListCountsForUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", (String.fromInt userId), "counts" ]
        []



-- JSON


encodeForApi : ( Count, Float ) -> E.Value
encodeForApi ( origCount, newCount ) =
    E.object
        [ ( "count"
          , E.object
                [ ( "count", E.float newCount )
                , ( "food_id", E.int origCount.food_id )
                , ( "user_id", E.int origCount.user_id )
                ]
          )
        ]


encode : Count -> E.Value
encode count =
    E.object
        [ ( "count", E.float count.count )
        , ( "food_id", E.int count.food_id )
        , ( "user_id", E.int count.user_id )
        , ( "id", E.int count.id )
        ]


decode : D.Decoder Count
decode =
    D.map4 Count
        (D.at [ "id" ] D.int)
        (D.at [ "user_id" ] D.int)
        (D.at [ "food_id" ] D.int)
        (D.at [ "count" ] D.float)
