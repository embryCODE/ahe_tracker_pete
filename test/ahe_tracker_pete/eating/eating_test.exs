defmodule AheTrackerPete.EatingTest do
  use AheTrackerPete.DataCase

  alias AheTrackerPete.Eating

  describe "foods" do
    alias AheTrackerPete.Eating.Food

    @valid_attrs %{category: "some category", name: "some name"}
    @update_attrs %{category: "some updated category", name: "some updated name"}
    @invalid_attrs %{category: nil, name: nil}

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

    @valid_attrs %{"": 120.5, count: "some count"}
    @update_attrs %{"": 456.7, count: "some updated count"}
    @invalid_attrs %{"": nil, count: nil}

    def count_fixture(attrs \\ %{}) do
      {:ok, count} =
        attrs
        |> Enum.into(@valid_attrs)
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
      assert {:ok, %Count{} = count} = Eating.create_count(@valid_attrs)
      assert count. == 120.5
      assert count.count == "some count"
    end

    test "create_count/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Eating.create_count(@invalid_attrs)
    end

    test "update_count/2 with valid data updates the count" do
      count = count_fixture()
      assert {:ok, %Count{} = count} = Eating.update_count(count, @update_attrs)

      
      assert count. == 456.7
      assert count.count == "some updated count"
    end

    test "update_count/2 with invalid data returns error changeset" do
      count = count_fixture()
      assert {:error, %Ecto.Changeset{}} = Eating.update_count(count, @invalid_attrs)
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
