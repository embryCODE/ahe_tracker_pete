module Types exposing (..)

import Http


type alias Model =
    { userIdInput : String
    , user : User
    , foods : List Food
    , counts : List Count
    , errors : List CustomError
    }


type alias User =
    { first_name : String
    , last_name : String
    , email : String
    , id : Int
    }


type alias Food =
    { name : String
    , category : String
    , id : Int
    , priority : Int
    }


type alias Count =
    { count : Float
    , user_id : Int
    , food_id : Int
    , id : Int
    }


type Msg
    = CountUpdated (Result Http.Error Count)
    | UpdateFoodCount ( Count, Float )
    | UpdateUserIdInput String
    | Login (Maybe Int)
    | ReceiveUser (Result Http.Error User)
    | ReceiveFoods (Result Http.Error (List Food))
    | ReceiveCountsForUser (Result Http.Error (List Count))


type alias FoodCount =
    { food : Food
    , count : Count
    }


type alias CategoryGroup =
    ( Category, List FoodCount )


type Category
    = Essential
    | Recommended
    | Acceptable


type CustomError
    = LoggingIn
