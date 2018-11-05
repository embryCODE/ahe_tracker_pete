defmodule AheTrackerPeteWeb.CountControllerTest do
  use AheTrackerPeteWeb.ConnCase

  alias AheTrackerPete.Accounts
  alias AheTrackerPete.Eating
  alias AheTrackerPete.Eating.Count

  defp valid_attrs(), do: create_attrs(120.5)
  defp update_attrs(), do: create_attrs(456.7)
  defp invalid_attrs(), do: create_attrs(nil)

  defp create_attrs(counts_count) do
    {:ok, food} =
      Eating.create_or_update_food(%{name: "Vegetables", category: "Essential", priority: 1}, 1)

    {:ok, user} =
      Accounts.create_user(%{
        first_name: "Testy",
        last_name: "McTesterson",
        email: "testy@example.com",
        password: "password"
      })

    %{count: counts_count, user_id: user.id, food_id: food.id}
  end

  def fixture(:count) do
    {:ok, count} = Eating.create_count(valid_attrs())
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
      conn = post(conn, Routes.count_path(conn, :create), count: valid_attrs())
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.count_path(conn, :show, id))

      assert %{
               "id" => id,
               "count" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.count_path(conn, :create), count: invalid_attrs())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update count" do
    setup [:create_count]

    test "renders count when data is valid", %{conn: conn, count: %Count{id: id} = count} do
      conn = put(conn, Routes.count_path(conn, :update, count), count: update_attrs())
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.count_path(conn, :show, id))

      assert %{
               "id" => id,
               "count" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, count: count} do
      conn = put(conn, Routes.count_path(conn, :update, count), count: invalid_attrs())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete count" do
    setup [:create_count]

    test "deletes chosen count", %{conn: conn, count: count} do
      conn = delete(conn, Routes.count_path(conn, :delete, count))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.count_path(conn, :show, count))
      end)
    end
  end

  defp create_count(_) do
    count = fixture(:count)
    {:ok, count: count}
  end
end
