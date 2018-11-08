module Category exposing (Category, listCategoriesRequest, encode, decode)

import Http
import Json.Decode as D
import Json.Encode as E
import Url.Builder as Url


type alias Category =
    { id : Int
    , name : String
    , priority : Int
    }



-- LIST CATEGORIES


listCategoriesRequest : Http.Request (List Category)
listCategoriesRequest =
    Http.get (toReadCategoriesUrl) (D.field "data" (D.list decode))


toReadCategoriesUrl : String
toReadCategoriesUrl =
    Url.crossOrigin "http://localhost:4000" [ "api", "categories" ] []



-- JSON


encode : Category -> E.Value
encode category =
    E.object
        [ ( "id", E.int category.id )
        , ( "name", E.string category.name )
        , ( "priority", E.int category.priority )
        ]


decode : D.Decoder Category
decode =
    D.map3 Category
        (D.at [ "id" ] D.int)
        (D.at [ "name" ] D.string)
        (D.at [ "priority" ] D.int)
