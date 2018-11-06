module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import List
import Debug
import Http
import User exposing (User)
import Food exposing (Food)
import Count exposing (Count)


-- TYPES


type alias CategoryGroup =
    ( Category, List FoodCount )


type Category
    = Essential
    | Recommended
    | Acceptable


type alias FoodCount =
    { food : Food
    , count : Count
    }


type CustomError
    = LoggingIn



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
    { userIdInput : String
    , user : User
    , foods : List Food
    , counts : List Count
    , errors : List CustomError
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( emptyModel, (Http.send ReceiveFoods Food.listFoodsRequest) )


emptyModel =
    Model "" emptyUser [ Food 0 "" "" 0 ] [ Count 0 0 0 0 ] []


emptyUser =
    (User 0 "" "" "")



-- UPDATE


type Msg
    = Login (Maybe Int)
    | Logout
    | UpdateUserIdInput String
    | UpdateFoodCount ( Count, Float )
    | CountUpdated (Result Http.Error Count)
    | ReceiveUser (Result Http.Error User)
    | ReceiveFoods (Result Http.Error (List Food))
    | ReceiveCountsForUser (Result Http.Error (List Count))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CountUpdated result ->
            case result of
                Ok _ ->
                    ( model, (Http.send ReceiveCountsForUser (Count.listCountsForUserRequest model.user.id)) )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        UpdateFoodCount args ->
            ( model, (Http.send CountUpdated (Count.updateCountRequest args)) )

        UpdateUserIdInput value ->
            ( { model | userIdInput = value }, Cmd.none )

        Login value ->
            case value of
                Just userId ->
                    ( { model | errors = (model.errors |> List.filter (\customError -> customError /= LoggingIn)) }
                    , Cmd.batch
                        [ Http.send ReceiveUser (User.readUserRequest userId)
                        , Http.send ReceiveCountsForUser (Count.listCountsForUserRequest userId)
                        ]
                    )

                Nothing ->
                    ( { model | errors = LoggingIn :: model.errors, userIdInput = "" }, Cmd.none )

        Logout ->
            ( { model | user = emptyUser, userIdInput = "" }, Cmd.none )

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
    div [ Attributes.class "pa3" ]
        [ (if model.user.id == 0 then
            renderLoginView model
           else
            renderMainView model
          )
        , div [ Attributes.class "strong", Attributes.class "mt3" ]
            [ div [] [ text "ERRORS:" ]
            , ul []
                (model.errors
                    |> List.map (\error -> li [] [ text (convertErrorToString LoggingIn) ])
                )
            ]
        ]


renderLoginView : Model -> Html Msg
renderLoginView model =
    Html.form [ Events.onSubmit (Login (String.toInt model.userIdInput)) ]
        [ input
            [ Attributes.placeholder "Enter User ID"
            , Events.onInput (UpdateUserIdInput)
            , Attributes.value model.userIdInput
            ]
            []
        , button [] [ text "Login" ]
        ]


renderMainView : Model -> Html Msg
renderMainView model =
    let
        categoryGroups =
            formatFoods model.user model.foods model.counts
    in
        div []
            [ button [ Events.onClick Logout ] [ text "Logout" ]
            , div []
                [ p [] [ text (model.user.first_name ++ " " ++ model.user.last_name) ]
                , p [] [ text model.user.email ]
                ]
            , div []
                [ div []
                    (categoryGroups |> List.map (renderCategoryGroup model))
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
            (foodCounts
                |> List.sortWith compareFoodPriority
                |> List.map (renderFoodCount model)
            )
        ]


compareFoodPriority : FoodCount -> FoodCount -> Order
compareFoodPriority foodCount1 foodCount2 =
    compare foodCount1.food.priority foodCount2.food.priority


renderFoodCount : Model -> { food : Food, count : Count } -> Html Msg
renderFoodCount model { food, count } =
    li []
        [ span
            [ Attributes.class "pointer"
            , Events.onClick (handleCountInput model (FoodCount food count) (count.count - 0.5))
            ]
            [ text "< " ]
        , span [] [ text (String.fromFloat count.count) ]
        , span
            [ Attributes.class "pointer"
            , Events.onClick (handleCountInput model (FoodCount food count) (count.count + 0.5))
            ]
            [ text " > " ]
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
    List.foldl processFood [] foods


processFood : Food -> List ( Category, List Food ) -> List ( Category, List Food )
processFood food acc =
    -- look at food.category, convert to Category type
    let
        currentFoodCategory =
            (convertStringToCategory food.category)
    in
        -- if the acc has a tuple with that Category,
        if
            acc
                |> List.any (\catTupleToTest -> (Tuple.first catTupleToTest) == currentFoodCategory)
        then
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
