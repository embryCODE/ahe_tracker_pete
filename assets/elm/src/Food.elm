module Food exposing (Food, listFoods)

import Http
import Json.Decode as D
import Json.Encode as E
import Url.Builder as Url


type alias Food =
    { name : String
    , category : String
    , id : Int
    , priority : Int
    }


listFoods : Http.Request (List Food)
listFoods =
    Http.get (toReadFoodsUrl) (D.field "data" (D.list decode))


toReadFoodsUrl : String
toReadFoodsUrl =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "foods" ]
        []


decode : D.Decoder Food
decode =
    D.map4 Food
        (D.at [ "name" ] D.string)
        (D.at [ "category" ] D.string)
        (D.at [ "id" ] D.int)
        (D.at [ "priority" ] D.int)
