module User exposing (User, readUserRequest, encode, decode)

import Http
import Json.Decode as D
import Json.Encode as E
import Url.Builder as Url


type alias User =
    { id : Int
    , first_name : String
    , last_name : String
    , email : String
    }



-- READ USER


readUserRequest : Int -> Http.Request User
readUserRequest userId =
    Http.get (toReadUserUrl userId) decodeFromApi


toReadUserUrl : Int -> String
toReadUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", (String.fromInt userId) ]
        []



-- JSON


encode : User -> E.Value
encode user =
    E.object
        [ ( "email", E.string user.email )
        , ( "first_name", E.string user.first_name )
        , ( "last_name", E.string user.last_name )
        , ( "id", E.int user.id )
        ]


decode : D.Decoder User
decode =
    D.map4 User
        (D.at [ "id" ] D.int)
        (D.at [ "first_name" ] D.string)
        (D.at [ "last_name" ] D.string)
        (D.at [ "email" ] D.string)


decodeFromApi : D.Decoder User
decodeFromApi =
    D.field "data"
        decode
