module User exposing (User, readUser)

import Http
import Json.Decode as D
import Json.Encode as E
import Url.Builder as Url


type alias User =
    { first_name : String
    , last_name : String
    , email : String
    , id : Int
    }



-- readUser


readUser : Int -> Http.Request User
readUser userId =
    Http.get (toReadUserUrl userId) userDecoder


toReadUserUrl : Int -> String
toReadUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", (String.fromInt userId) ]
        []


userDecoder : D.Decoder User
userDecoder =
    D.field "data"
        (D.map4 User
            (D.at [ "first_name" ] D.string)
            (D.at [ "last_name" ] D.string)
            (D.at [ "email" ] D.string)
            (D.at [ "id" ] D.int)
        )
