module Food exposing (Food, listFoodsRequest, encode, decode)

import Http
import Json.Decode as D
import Json.Encode as E
import Url.Builder as Url


type alias Food =
    { id : Int
    , name : String
    , category_id : Int
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


encode : Food -> E.Value
encode food =
    E.object
        [ ( "name", E.string food.name )
        , ( "category_id", E.int food.category_id )
        , ( "priority", E.int food.priority )
        , ( "id", E.int food.id )
        ]


decode : D.Decoder Food
decode =
    D.map4 Food
        (D.at [ "id" ] D.int)
        (D.at [ "name" ] D.string)
        (D.at [ "category_id" ] D.int)
        (D.at [ "priority" ] D.int)
