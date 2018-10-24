defmodule AheTrackerPeteWeb.FoodController do
  use AheTrackerPeteWeb, :controller

  alias AheTrackerPete.Eating
  alias AheTrackerPete.Eating.Food

  action_fallback AheTrackerPeteWeb.FallbackController

  def index(conn, _params) do
    foods = Eating.list_foods()
    render(conn, "index.json", foods: foods)
  end

  def create(conn, %{"food" => food_params}) do
    with {:ok, %Food{} = food} <- Eating.create_food(food_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.food_path(conn, :show, food))
      |> render("show.json", food: food)
    end
  end

  def show(conn, %{"id" => id}) do
    food = Eating.get_food!(id)
    render(conn, "show.json", food: food)
  end

  def update(conn, %{"id" => id, "food" => food_params}) do
    food = Eating.get_food!(id)

    with {:ok, %Food{} = food} <- Eating.update_food(food, food_params) do
      render(conn, "show.json", food: food)
    end
  end

  def delete(conn, %{"id" => id}) do
    food = Eating.get_food!(id)

    with {:ok, %Food{}} <- Eating.delete_food(food) do
      send_resp(conn, :no_content, "")
    end
  end
end
