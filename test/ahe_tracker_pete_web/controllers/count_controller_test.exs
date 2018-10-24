defmodule AheTrackerPeteWeb.CountControllerTest do
  use AheTrackerPeteWeb.ConnCase

  alias AheTrackerPete.Eating
  alias AheTrackerPete.Eating.Count

  @create_attrs %{
    : 120.5,
    count: "some count"
  }
  @update_attrs %{
    : 456.7,
    count: "some updated count"
  }
  @invalid_attrs %{"": nil, count: nil}

  def fixture(:count) do
    {:ok, count} = Eating.create_count(@create_attrs)
    count
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all counts", %{conn: conn} do
      conn = get(conn, Routes.count_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create count" do
    test "renders count when data is valid", %{conn: conn} do
      conn = post(conn, Routes.count_path(conn, :create), count: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.count_path(conn, :show, id))

      assert %{
               "id" => id,
               "" => 120.5,
               "count" => "some count"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.count_path(conn, :create), count: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update count" do
    setup [:create_count]

    test "renders count when data is valid", %{conn: conn, count: %Count{id: id} = count} do
      conn = put(conn, Routes.count_path(conn, :update, count), count: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.count_path(conn, :show, id))

      assert %{
               "id" => id,
               "" => 456.7,
               "count" => "some updated count"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, count: count} do
      conn = put(conn, Routes.count_path(conn, :update, count), count: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete count" do
    setup [:create_count]

    test "deletes chosen count", %{conn: conn, count: count} do
      conn = delete(conn, Routes.count_path(conn, :delete, count))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.count_path(conn, :show, count))
      end
    end
  end

  defp create_count(_) do
    count = fixture(:count)
    {:ok, count: count}
  end
end
