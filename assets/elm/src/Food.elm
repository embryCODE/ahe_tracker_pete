module Food exposing (Food, listFoodsRequest)

import Http
import Json.Decode as D
import Json.Encode as E
import Url.Builder as Url


type alias Food =
    { id : Int
    , name : String
    , category : String
    , priority : Int
    }



-- LIST FOODS


listFoodsRequest : Http.Request (List Food)
listFoodsRequest =
    Http.get (toReadFoodsUrl) (D.field "data" (D.list decode))


toReadFoodsUrl : String
toReadFoodsUrl =
    Url.crossOrigin "http://localhost:4000" [ "api", "foods" ] []



-- JSON


decode : D.Decoder Food
decode =
    D.map4 Food
        (D.at [ "id" ] D.int)
        (D.at [ "name" ] D.string)
        (D.at [ "category" ] D.string)
        (D.at [ "priority" ] D.int)
