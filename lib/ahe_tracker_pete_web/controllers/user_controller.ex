defmodule AheTrackerPeteWeb.UserController do
  use AheTrackerPeteWeb, :controller

  alias AheTrackerPete.Accounts
  alias AheTrackerPete.Accounts.User

  action_fallback(AheTrackerPeteWeb.FallbackController)

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      Accounts.init_counts_for_user(user)

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def list_counts_for_user(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    counts = Accounts.list_counts_for_user(user)

    render(conn, "user_with_counts.json", user: user, counts: counts)
  end
end
