defmodule AheTrackerPeteWeb.CountControllerTest do
  use AheTrackerPeteWeb.ConnCase

  alias AheTrackerPete.Accounts
  alias AheTrackerPete.Eating
  alias AheTrackerPete.Eating.Count

  defp valid_count_attrs(), do: create_count_attrs(120.5)
  defp update_count_attrs(), do: create_count_attrs(456.7)
  defp invalid_count_attrs(), do: create_count_attrs(nil)

  defp create_count_attrs(counts_count) do
    Eating.create_or_update_category(%{name: "Fake Category 1", priority: 1}, 1)

    Eating.create_or_update_food(%{name: "Vegetables", category_id: 1, priority: 1}, 1)

    Accounts.create_or_update_user(
      %{
        first_name: "Testy",
        last_name: "McTesterson",
        email: "testy@example.com",
        password: "password",
        password_confirmation: "password"
      },
      1
    )

    %{count: counts_count, user_id: 1, food_id: 1}
  end

  def fixture(:count) do
    {:ok, count} = Eating.create_count(valid_count_attrs())
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
      conn = post(conn, Routes.count_path(conn, :create), count: valid_count_attrs())
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.count_path(conn, :show, id))

      assert %{
               "id" => id,
               "count" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.count_path(conn, :create), count: invalid_count_attrs())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update count" do
    setup [:create_count]

    test "renders count when data is valid", %{conn: conn, count: %Count{id: id} = count} do
      conn = put(conn, Routes.count_path(conn, :update, count), count: update_count_attrs())
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.count_path(conn, :show, id))

      assert %{
               "id" => id,
               "count" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, count: count} do
      conn = put(conn, Routes.count_path(conn, :update, count), count: invalid_count_attrs())
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
