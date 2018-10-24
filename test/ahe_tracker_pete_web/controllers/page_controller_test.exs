defmodule AheTrackerPeteWeb.PageControllerTest do
  use AheTrackerPeteWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    # This test just checks that the html returned from / contains this string
    assert html_response(conn, 200) =~ "If you see this text, Elm is broken."
  end
end
