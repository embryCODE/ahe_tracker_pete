defmodule AheTrackerPete.EatingTest do
  use AheTrackerPete.DataCase

  alias AheTrackerPete.Accounts
  alias AheTrackerPete.Eating

  describe "foods" do
    alias AheTrackerPete.Eating.Food

    defp valid_food_attrs() do
      Eating.create_or_update_category(%{name: "Fake Category 1", priority: 1}, 1)

      %{category_id: 1, name: "some name", priority: 1}
    end

    defp update_food_attrs() do
      Eating.create_or_update_category(%{name: "Fake Category 2", priority: 2}, 2)

      %{category_id: 2, name: "some updated name", priority: 2}
    end

    defp invalid_food_attrs() do
      %{category: nil, name: nil}
    end

    def food_fixture(attrs \\ %{}) do
      {:ok, food} =
        attrs
        |> Enum.into(valid_food_attrs())
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
      assert {:ok, %Food{} = food} = Eating.create_food(valid_food_attrs())
      assert food.category_id == 1
      assert food.name == "some name"
    end

    test "create_food/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Eating.create_food(invalid_food_attrs())
    end

    test "update_food/2 with valid data updates the food" do
      food = food_fixture()
      assert {:ok, %Food{} = food} = Eating.update_food(food, update_food_attrs())

      assert food.category_id == 2
      assert food.name == "some updated name"
    end

    test "update_food/2 with invalid data returns error changeset" do
      food = food_fixture()
      assert {:error, %Ecto.Changeset{}} = Eating.update_food(food, invalid_food_attrs())
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

    def count_fixture(attrs \\ %{}) do
      {:ok, count} =
        attrs
        |> Enum.into(valid_count_attrs())
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
      assert {:ok, %Count{} = count} = Eating.create_count(valid_count_attrs())
      assert count.count == 120.5
    end

    test "create_count/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Eating.create_count(invalid_count_attrs())
    end

    test "update_count/2 with valid data updates the count" do
      count = count_fixture()
      assert {:ok, %Count{} = count} = Eating.update_count(count, update_count_attrs())

      assert count.count == 456.7
    end

    test "update_count/2 with invalid data returns error changeset" do
      count = count_fixture()
      assert {:error, %Ecto.Changeset{}} = Eating.update_count(count, invalid_count_attrs())
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

  describe "categories" do
    alias AheTrackerPete.Eating.Category

    @valid_category_attrs %{name: "some name", priority: 42}
    @update_category_attrs %{name: "some updated name", priority: 43}
    @invalid_category_attrs %{name: nil, priority: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_category_attrs)
        |> Eating.create_category()

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Eating.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Eating.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Eating.create_category(@valid_category_attrs)
      assert category.name == "some name"
      assert category.priority == 42
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Eating.create_category(@invalid_category_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()

      assert {:ok, %Category{} = category} =
               Eating.update_category(category, @update_category_attrs)

      assert category.name == "some updated name"
      assert category.priority == 43
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Eating.update_category(category, @invalid_category_attrs)

      assert category == Eating.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Eating.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Eating.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Eating.change_category(category)
    end
  end
end
