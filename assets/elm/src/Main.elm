module Main exposing (..)

import Types exposing (..)
import Comms exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (foldl)
import Debug


-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, listFoods )


initialModel =
    Model "" (User "" "" "" 0) [ Food "" "" 0 ] [ Count 0 0 0 0 ] []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CountUpdated result ->
            case result of
                Ok _ ->
                    ( model, (listCountsForUser model.user.id) )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        UpdateFoodCount args ->
            ( model, (updateFoodCount args) )

        UpdateUserIdInput value ->
            ( { model | userIdInput = value }, Cmd.none )

        Login value ->
            case value of
                Just userId ->
                    ( { model | errors = (model.errors |> List.filter (\customError -> customError /= LoggingIn)) }
                    , Cmd.batch [ readUser userId, listCountsForUser userId ]
                    )

                Nothing ->
                    ( { model | errors = LoggingIn :: model.errors, userIdInput = "" }, Cmd.none )

        ReceiveUser value ->
            case value of
                Ok user ->
                    ( { model
                        | user = user
                        , errors = (model.errors |> List.filter (\customError -> customError /= LoggingIn))
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | errors = LoggingIn :: model.errors, userIdInput = "" }, Cmd.none )

        ReceiveFoods value ->
            case value of
                Ok foods ->
                    ( { model | foods = foods }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        ReceiveCountsForUser value ->
            case value of
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
    let
        categoryGroups =
            formatFoods model.user model.foods model.counts
    in
        div [ class "pa3" ]
            [ Html.form [ onSubmit (Login (String.toInt model.userIdInput)) ]
                [ input
                    [ placeholder "Enter User ID", onInput (UpdateUserIdInput), value model.userIdInput ]
                    []
                , button [] [ text "Login" ]
                ]
            , div []
                [ p [] [ text (model.user.first_name ++ " " ++ model.user.last_name) ]
                , p [] [ text model.user.email ]
                ]
            , div []
                [ div []
                    (categoryGroups |> List.map (renderCategoryGroup model))
                ]
            , div [ class "strong" ]
                [ div [] [ text "ERRORS:" ]
                , ul []
                    (model.errors |> List.map (\error -> li [] [ text (convertErrorToString LoggingIn) ]))
                ]
            ]


convertErrorToString : CustomError -> String
convertErrorToString customError =
    case customError of
        LoggingIn ->
            "There was an error logging in"


renderCategoryGroup : Model -> ( Category, List FoodCount ) -> Html Msg
renderCategoryGroup model ( categoryName, foodCounts ) =
    div []
        [ p [] [ text (convertCategoryToString categoryName) ]
        , ul []
            (foodCounts |> List.map (renderFoodCount model))
        ]


renderFoodCount : Model -> { food : Food, count : Count } -> Html Msg
renderFoodCount model { food, count } =
    li []
        [ span [ class "pointer", onClick (handleCountInput model (FoodCount food count) (count.count - 0.5)) ] [ text "< " ]
        , span [] [ text (String.fromFloat count.count) ]
        , span [ class "pointer", onClick (handleCountInput model (FoodCount food count) (count.count + 0.5)) ] [ text " > " ]
        , text food.name
        ]


handleCountInput : Model -> FoodCount -> Float -> Msg
handleCountInput model { count, food } newCount =
    UpdateFoodCount ( count, newCount )


convertCategoryToString : Category -> String
convertCategoryToString category =
    case category of
        Essential ->
            "Essential"

        Recommended ->
            "Recommended"

        Acceptable ->
            "Acceptable"


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
                FoodCount food countThatWasFound

            -- Otherwise assume the count for that food is 0
            Nothing ->
                FoodCount food (Count 0 0 0 0)


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
