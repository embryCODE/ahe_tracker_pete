module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (..)
import Url.Builder as Url
import Debug
import List exposing (foldl)


-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { user : User, foods : List Food, counts : List Count }


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
    }


type alias Count =
    { count : Float
    , user_id : Int
    , food_id : Int
    , id : Int
    }


initialModel =
    { user = User "" "" "" 0
    , foods =
        [ Food "" "" 0 ]
    , counts =
        [ Count 0 0 0 0 ]
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.batch [ readUser "2", listFoods, listCountsForUser 2 ]
    )



-- UPDATE


type Msg
    = ReceiveUser (Result Http.Error User)
    | ReceiveFoods (Result Http.Error (List Food))
    | ReceiveCounts (Result Http.Error (List Count))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveUser result ->
            let
                _ =
                    Debug.log "Debug ReceiveUser" result
            in
                case result of
                    Ok user ->
                        ( { model | user = user }
                        , Cmd.none
                        )

                    Err _ ->
                        ( model
                        , Cmd.none
                        )

        ReceiveFoods result ->
            let
                _ =
                    Debug.log "Debug ReceiveFoods" result
            in
                case result of
                    Ok foods ->
                        ( { model | foods = foods }
                        , Cmd.none
                        )

                    Err _ ->
                        ( model
                        , Cmd.none
                        )

        ReceiveCounts result ->
            let
                _ =
                    Debug.log "Debug ReceiveCounts" result
            in
                case result of
                    Ok counts ->
                        ( { model | counts = counts }
                        , Cmd.none
                        )

                    Err _ ->
                        ( model
                        , Cmd.none
                        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ p [] [ text (model.user.first_name ++ " " ++ model.user.last_name) ]
            , p [] [ text model.user.email ]
            ]
        , div []
            [ div []
                (List.map
                    (\( categoryName, foodsInCategory ) ->
                        div []
                            [ p [] [ text (convertCategoryToString categoryName) ]
                            , ul []
                                (List.map
                                    (\food -> li [] [ text (food.name ++ " " ++ (String.fromFloat food.count)) ])
                                    foodsInCategory
                                )
                            ]
                    )
                    (formatFoods model.user model.foods model.counts)
                )
            ]
        ]


convertCategoryToString : Category -> String
convertCategoryToString category =
    case category of
        Essential ->
            "Essential"

        Recommended ->
            "Recommended"

        Acceptable ->
            "Acceptable"


type alias FoodCount =
    { name : String
    , count : Float
    }


type alias CategoryGroup =
    ( Category, List FoodCount )


type Category
    = Essential
    | Recommended
    | Acceptable


formatFoods : User -> List Food -> List Count -> List CategoryGroup
formatFoods user foodsFromApi countsFromApi =
    foodsFromApi
        |> processFoodsByCategory
        |> addCountsToFoodsByCategory user countsFromApi
        |> orderByCategory


processFoodsByCategory : List Food -> List ( Category, List Food )
processFoodsByCategory foods =
    foldl processFood [] foods


processFood : Food -> List ( Category, List Food ) -> List ( Category, List Food )
processFood food acc =
    -- look at food.category, convert to Category type
    let
        currentFoodCategory =
            (convertStringToCategory food.category)
    in
        -- if the acc has a tuple with that Category,
        if acc |> List.any (\catTupleToTest -> (Tuple.first catTupleToTest) == currentFoodCategory) then
            -- add this food to the list of foods in that tuple
            acc
                |> List.map
                    (\( cat, foodListToAddTo ) ->
                        if cat == currentFoodCategory then
                            ( cat, food :: foodListToAddTo )
                        else
                            ( cat, foodListToAddTo )
                    )
        else
            -- otherwise, add that tuple to the list and plug this food into the list of foods in that tuple
            ( currentFoodCategory, [ food ] ) :: acc


convertStringToCategory : String -> Category
convertStringToCategory string =
    case string of
        "Essential" ->
            Essential

        "Recommended" ->
            Recommended

        "Acceptable" ->
            Acceptable

        _ ->
            Essential


addCountsToFoodsByCategory : User -> List Count -> List ( Category, List Food ) -> List CategoryGroup
addCountsToFoodsByCategory user counts list =
    list
        -- For each tuple in the list
        |> List.map
            (\( category, foodList ) ->
                -- Look at each food in the second item of the tuple and replace it with a FoodCount
                ( category, (List.map (\food -> replaceFoodWithFoodCount user counts food) foodList) )
            )


replaceFoodWithFoodCount : User -> List Count -> Food -> FoodCount
replaceFoodWithFoodCount user counts food =
    -- Look at every member of the list of counts
    let
        foundCount =
            List.head
                (List.filter
                    (\count ->
                        -- If count.food_id === food.id and count.user_id === user.id
                        (count.food_id == food.id) && (count.user_id == user.id)
                    )
                    counts
                )
    in
        -- Return a FoodCount with food.name and the found count.count
        case foundCount of
            Just countThatWasFound ->
                FoodCount food.name countThatWasFound.count

            -- Otherwise assume the count for that food is 0
            Nothing ->
                FoodCount food.name 0


orderByCategory : List CategoryGroup -> List CategoryGroup
orderByCategory listToOrder =
    listToOrder |> List.sortWith sortByCategory


sortByCategory : CategoryGroup -> CategoryGroup -> Order
sortByCategory ( category1, _ ) ( category2, _ ) =
    case ( category1, category2 ) of
        ( Essential, Recommended ) ->
            LT

        ( Essential, Acceptable ) ->
            LT

        ( Recommended, Acceptable ) ->
            LT

        ( Recommended, Essential ) ->
            GT

        ( Acceptable, Essential ) ->
            GT

        ( Acceptable, Recommended ) ->
            GT

        _ ->
            EQ



-- HTTP
-- readUser


readUser : String -> Cmd Msg
readUser userId =
    Http.send ReceiveUser (Http.get (toReadUserUrl userId) userDecoder)


toReadUserUrl : String -> String
toReadUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", userId ]
        []


userDecoder : Decoder User
userDecoder =
    field "data"
        (map4 User
            (at [ "first_name" ] string)
            (at [ "last_name" ] string)
            (at [ "email" ] string)
            (at [ "id" ] int)
        )



-- listFoods


listFoods : Cmd Msg
listFoods =
    Http.send ReceiveFoods (Http.get (toReadFoodsUrl) foodListDecoder)


toReadFoodsUrl : String
toReadFoodsUrl =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "foods" ]
        []


foodListDecoder : Decoder (List Food)
foodListDecoder =
    field "data" (Decode.list foodDecoder)


foodDecoder : Decoder Food
foodDecoder =
    map3 Food
        (at [ "name" ] string)
        (at [ "category" ] string)
        (at [ "id" ] int)



-- listCountsForUser


listCountsForUser : Int -> Cmd Msg
listCountsForUser userId =
    Http.send ReceiveCounts (Http.get (toListCountsForUserUrl userId) countListDecoder)


toListCountsForUserUrl : Int -> String
toListCountsForUserUrl userId =
    Url.crossOrigin "http://localhost:4000"
        [ "api", "users", (String.fromInt userId), "counts" ]
        []


countListDecoder : Decoder (List Count)
countListDecoder =
    field "counts" (Decode.list countDecoder)


countDecoder : Decoder Count
countDecoder =
    map4 Count
        (at [ "count" ] float)
        (at [ "user_id" ] int)
        (at [ "food_id" ] int)
        (at [ "id" ] int)
