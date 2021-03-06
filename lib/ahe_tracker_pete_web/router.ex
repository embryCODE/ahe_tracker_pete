defmodule AheTrackerPeteWeb.Router do
  use AheTrackerPeteWeb, :router

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

  scope "/", AheTrackerPeteWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  scope "/api", AheTrackerPeteWeb do
    pipe_through(:api)

    resources("/users", UserController, except: [:new, :edit])
    get("/users/:id/counts", UserController, :list_counts_for_user)

    resources("/foods", FoodController, except: [:new, :edit])
    resources("/counts", CountController, except: [:new, :edit])
    resources("/categories", CategoryController, except: [:new, :edit])
  end
end
