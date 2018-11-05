defmodule AheTrackerPete.EatingTest do
  use AheTrackerPete.DataCase

  alias AheTrackerPete.Accounts
  alias AheTrackerPete.Eating

  describe "foods" do
    alias AheTrackerPete.Eating.Food

    @valid_attrs %{category: "some category", name: "some name", priority: 1}
    @update_attrs %{category: "some updated category", name: "some updated name", priority: 1}
    @invalid_attrs %{category: nil, name: nil, priority: nil}

    def food_fixture(attrs \\ %{}) do
      {:ok, food} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Eating.create_food()

      food
    end

    test "list_foods/0 returns all foods" do
      food = food_fixture()
      assert Eating.list_foods() == [food]
    end

    test "get_food!/1 returns the food with given id" do
      food = food_fixture()
      assert Eating.get_food!(food.id) == food
    end

    test "create_food/1 with valid data creates a food" do
      assert {:ok, %Food{} = food} = Eating.create_food(@valid_attrs)
      assert food.category == "some category"
      assert food.name == "some name"
    end

    test "create_food/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Eating.create_food(@invalid_attrs)
    end

    test "update_food/2 with valid data updates the food" do
      food = food_fixture()
      assert {:ok, %Food{} = food} = Eating.update_food(food, @update_attrs)

      assert food.category == "some updated category"
      assert food.name == "some updated name"
    end

    test "update_food/2 with invalid data returns error changeset" do
      food = food_fixture()
      assert {:error, %Ecto.Changeset{}} = Eating.update_food(food, @invalid_attrs)
      assert food == Eating.get_food!(food.id)
    end

    test "delete_food/1 deletes the food" do
      food = food_fixture()
      assert {:ok, %Food{}} = Eating.delete_food(food)
      assert_raise Ecto.NoResultsError, fn -> Eating.get_food!(food.id) end
    end

    test "change_food/1 returns a food changeset" do
      food = food_fixture()
      assert %Ecto.Changeset{} = Eating.change_food(food)
    end
  end

  describe "counts" do
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

    def count_fixture(attrs \\ %{}) do
      {:ok, count} =
        attrs
        |> Enum.into(valid_attrs())
        |> Eating.create_count()

      count
    end

    test "list_counts/0 returns all counts" do
      count = count_fixture()
      assert Eating.list_counts() == [count]
    end

    test "get_count!/1 returns the count with given id" do
      count = count_fixture()
      assert Eating.get_count!(count.id) == count
    end

    test "create_count/1 with valid data creates a count" do
      assert {:ok, %Count{} = count} = Eating.create_count(valid_attrs())
      assert count.count == 120.5
    end

    test "create_count/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Eating.create_count(invalid_attrs())
    end

    test "update_count/2 with valid data updates the count" do
      count = count_fixture()
      assert {:ok, %Count{} = count} = Eating.update_count(count, update_attrs())

      assert count.count == 456.7
    end

    test "update_count/2 with invalid data returns error changeset" do
      count = count_fixture()
      assert {:error, %Ecto.Changeset{}} = Eating.update_count(count, invalid_attrs())
      assert count == Eating.get_count!(count.id)
    end

    test "delete_count/1 deletes the count" do
      count = count_fixture()
      assert {:ok, %Count{}} = Eating.delete_count(count)
      assert_raise Ecto.NoResultsError, fn -> Eating.get_count!(count.id) end
    end

    test "change_count/1 returns a count changeset" do
      count = count_fixture()
      assert %Ecto.Changeset{} = Eating.change_count(count)
    end
  end
end
