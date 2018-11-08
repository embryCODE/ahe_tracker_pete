defmodule AheTrackerPeteWeb.Router do
  use AheTrackerPeteWeb, :router

  alias AheTrackerPete.Guardian

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :jwt_authenticated do
    plug(Guardian.AuthPipeline)
  end

  scope "/", AheTrackerPeteWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Unauthenticated API requests
  scope "/api", AheTrackerPeteWeb do
    pipe_through(:api)

    post("/sign_up", UserController, :create)
    post("/sign_in", UserController, :sign_in)
  end

  # API requests requiring authorization
  scope "/api", AheTrackerPeteWeb do
    pipe_through([:api, :jwt_authenticated])

    get("/my_user", UserController, :show)
    get("/my_user/counts", UserController, :list_counts_for_user)
    put("/my_user/counts/:id", CountController, :update_count_for_user)

    resources("/foods", FoodController, except: [:new, :edit])
    resources("/categories", CategoryController, except: [:new, :edit])
  end
end
