defmodule AheTrackerPeteWeb.CountController do
  use AheTrackerPeteWeb, :controller

  alias AheTrackerPete.Eating
  alias AheTrackerPete.Eating.Count

  action_fallback(AheTrackerPeteWeb.FallbackController)

  def index(conn, _params) do
    counts = Eating.list_counts()
    render(conn, "index.json", counts: counts)
  end

  def create(conn, %{"count" => count_params}) do
    with {:ok, %Count{} = count} <- Eating.create_count(count_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.count_path(conn, :show, count))
      |> render("show.json", count: count)
    end
  end

  def show(conn, %{"id" => id}) do
    count = Eating.get_count!(id)
    render(conn, "show.json", count: count)
  end

  def update(conn, %{"id" => id, "count" => count_params}) do
    count = Eating.get_count!(id)

    with {:ok, %Count{} = count} <- Eating.update_count(count, count_params) do
      render(conn, "show.json", count: count)
    end
  end

  def delete(conn, %{"id" => id}) do
    count = Eating.get_count!(id)

    with {:ok, %Count{}} <- Eating.delete_count(count) do
      send_resp(conn, :no_content, "")
    end
  end

  def update_count_for_user(conn, %{"id" => id, "count" => count_params}) do
    user = Guardian.Plug.current_resource(conn)
    count = Eating.get_count_for_user!(id, user.id)

    with {:ok, %Count{} = count} <- Eating.update_count(count, count_params) do
      render(conn, "show.json", count: count)
    end
  end
end
