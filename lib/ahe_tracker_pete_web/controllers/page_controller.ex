defmodule AheTrackerPeteWeb.PageController do
  use AheTrackerPeteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
