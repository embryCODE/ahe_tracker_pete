module User exposing (User, readUserRequest)

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
    Http.get (toReadUserUrl userId) decode


toReadUserUrl : Int -> String
toReadUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", (String.fromInt userId) ]
        []



-- JSON


decode : D.Decoder User
decode =
    D.field "data"
        (D.map4 User
            (D.at [ "id" ] D.int)
            (D.at [ "first_name" ] D.string)
            (D.at [ "last_name" ] D.string)
            (D.at [ "email" ] D.string)
        )
