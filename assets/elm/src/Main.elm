port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import List
import Debug
import Http
import User exposing (User)
import Category exposing (Category)
import Food exposing (Food)
import Count exposing (Count)
import Json.Encode as E
import Json.Decode as D


-- TYPES


type alias CategoryGroup =
    ( Category, List FoodCount )


type alias FoodCount =
    ( Food, Maybe Count )


type Error
    = LoginError String



-- MAIN


main =
    Browser.element
        { init = init
        , update = updateWithStorage
        , subscriptions = subscriptions
        , view = view
        }


port setStorage : E.Value -> Cmd msg


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, origCommands ) =
            update msg model
    in
        ( newModel, Cmd.batch [ setStorage (convertModelToJson newModel), origCommands ] )


convertModelToJson : Model -> E.Value
convertModelToJson model =
    E.object
        [ ( "userIdInput", E.string model.userIdInput )
        , ( "user", User.encode model.user )
        , ( "categories", E.list Category.encode model.categories )
        , ( "foods", E.list Food.encode model.foods )
        , ( "counts", E.list Count.encode model.counts )
        , ( "errors", E.list convertErrorToJson model.errors )
        ]


convertErrorToJson : Error -> E.Value
convertErrorToJson error =
    E.string (convertErrorToString error)



-- MODEL


type alias Model =
    { userIdInput : String
    , user : User
    , categories : List Category
    , foods : List Food
    , counts : List Count
    , errors : List Error
    }


init : Maybe E.Value -> ( Model, Cmd Msg )
init maybeModel =
    case maybeModel of
        Just modelFromLocalStorage ->
            ( convertJsonToModel modelFromLocalStorage
            , Cmd.batch
                [ Http.send ReceiveFoods Food.listFoodsRequest
                , Http.send ReceiveCategories Category.listCategoriesRequest
                ]
            )

        Nothing ->
            ( emptyModel
            , Cmd.batch
                [ Http.send ReceiveFoods Food.listFoodsRequest
                , Http.send ReceiveCategories Category.listCategoriesRequest
                ]
            )


convertJsonToModel : E.Value -> Model
convertJsonToModel value =
    Result.withDefault emptyModel (D.decodeValue modelDecoder value)


modelDecoder =
    D.map6 Model
        (D.at [ "userIdInput" ] D.string)
        (D.at [ "user" ] User.decode)
        (D.at [ "categories" ] (D.list Category.decode))
        (D.at [ "foods" ] (D.list Food.decode))
        (D.at [ "counts" ] (D.list Count.decode))
        (D.at [ "errors" ] (D.list decodeError))


decodeError : D.Decoder Error
decodeError =
    D.map LoginError D.string


emptyModel =
    Model "" emptyUser [ Category 0 "" 0 ] [ Food 0 "" 0 0 ] [ Count 0 0 0 0 ] []


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
    | ReceiveCategories (Result Http.Error (List Category))
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
                    ( { model | errors = (model.errors |> List.filter (\error -> not (isLoginError error))) }
                    , Cmd.batch
                        [ Http.send ReceiveUser (User.readUserRequest userId)
                        , Http.send ReceiveCountsForUser (Count.listCountsForUserRequest userId)
                        ]
                    )

                Nothing ->
                    ( { model | errors = LoginError "Invalid user ID" :: model.errors, userIdInput = "" }, Cmd.none )

        Logout ->
            ( { model | user = emptyUser, userIdInput = "" }, Cmd.none )

        ReceiveUser value ->
            case value of
                Ok user ->
                    ( { model
                        | user = user
                        , errors = (model.errors |> List.filter (\error -> not (isLoginError error)))
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | errors = LoginError "User not found" :: model.errors, userIdInput = "" }, Cmd.none )

        ReceiveCategories value ->
            case value of
                Ok categories ->
                    ( { model | categories = categories }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

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


isLoginError : Error -> Bool
isLoginError error =
    case error of
        LoginError _ ->
            True



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ Attributes.class "pa3" ]
        ([ (if model.user.id == 0 then
                renderLoginView model
            else
                renderMainView model
           )
         ]
            ++ if List.length model.errors > 0 then
                [ renderErrorView model ]
               else
                []
        )


renderErrorView : Model -> Html Msg
renderErrorView model =
    div [ Attributes.class "red" ]
        (List.map
            (\error -> p [] [ text (convertErrorToString error) ])
            model.errors
        )


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
            createCategoryGroups model.categories model.foods model.counts
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


convertErrorToString : Error -> String
convertErrorToString error =
    case error of
        LoginError errorMessage ->
            errorMessage


renderCategoryGroup : Model -> ( Category, List FoodCount ) -> Html Msg
renderCategoryGroup model ( category, foodCounts ) =
    div []
        [ p [] [ text category.name ]
        , ul []
            (foodCounts
                |> List.map (renderFoodCount model)
            )
        ]


renderFoodCount : Model -> FoodCount -> Html Msg
renderFoodCount model ( food, maybeCount ) =
    case maybeCount of
        Just count ->
            li []
                [ span
                    [ Attributes.class "pointer"
                    , Events.onClick (UpdateFoodCount ( count, (count.count - 0.5) ))
                    ]
                    [ text "< " ]
                , span [] [ text (String.fromFloat count.count) ]
                , span
                    [ Attributes.class "pointer"
                    , Events.onClick (UpdateFoodCount ( count, (count.count + 0.5) ))
                    ]
                    [ text " > " ]
                , text food.name
                ]

        Nothing ->
            li [] [ text ("Database error with " ++ food.name) ]


createCategoryGroups : List Category -> List Food -> List Count -> List CategoryGroup
createCategoryGroups categories foods counts =
    categories
        |> List.sortWith (\cat1 cat2 -> (compare cat1.priority cat2.priority))
        |> List.map (\category -> ( category, createListOfFoodCounts category foods counts ))


createListOfFoodCounts : Category -> List Food -> List Count -> List FoodCount
createListOfFoodCounts category foods counts =
    foods
        |> List.filter (\food -> food.category_id == category.id)
        |> List.sortWith (\food1 food2 -> (compare food1.priority food2.priority))
        |> List.map (\food -> ( food, findMatchingCount food counts ))


findMatchingCount : Food -> List Count -> Maybe Count
findMatchingCount food counts =
    List.head (List.filter (\count -> count.food_id == food.id) counts)
