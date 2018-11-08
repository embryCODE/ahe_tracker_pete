defmodule AheTrackerPete.AccountsTest do
  use AheTrackerPete.DataCase

  alias AheTrackerPete.Accounts
  alias AheTrackerPete.Eating

  describe "users" do
    alias AheTrackerPete.Accounts.User

    @valid_user_attrs %{
      email: "example@example.com",
      first_name: "some first_name",
      last_name: "some last_name",
      password: "some password",
      password_confirmation: "some password"
    }
    @update_user_attrs %{
      email: "updated@example.com",
      first_name: "some updated first_name",
      last_name: "some updated last_name",
      password: "some updated password",
      password_confirmation: "some updated password"
    }
    @invalid_user_attrs %{
      email: nil,
      first_name: nil,
      last_name: nil,
      password: nil,
      password_confirmation: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_user_attrs)
        |> Accounts.create_user()

      %User{user | password: nil, password_confirmation: nil}
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_user_attrs)
      assert user.email == "example@example.com"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_user_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_user_attrs)

      assert user.email == "updated@example.com"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_user_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "list_counts_for_user/1 returns an empty list if there are no counts" do
      user = user_fixture()
      counts = Accounts.list_counts_for_user(user)
      assert [] == counts
    end

    test "list_counts_for_user/1 returns a list of counts if there are any" do
      Eating.create_or_update_category(%{name: "Fake Category 1", priority: 1}, 1)

      {:ok, vegetables} = Eating.create_food(%{name: "Vegetables", category_id: 1, priority: 1})

      {:ok, fruit} = Eating.create_food(%{name: "Fruit", category_id: 1, priority: 2})

      {:ok, user} =
        Accounts.create_user(%{
          first_name: "Testy",
          last_name: "McTesterson",
          email: "testy@example.com",
          password: "password",
          password_confirmation: "password"
        })

      Eating.create_count(%{
        user_id: user.id,
        food_id: vegetables.id,
        count: 1.5
      })

      Eating.create_count(%{
        user_id: user.id,
        food_id: fruit.id,
        count: 2.5
      })

      counts = Accounts.list_counts_for_user(user)

      assert Enum.count(counts) == 2
      assert Enum.at(counts, 0).food_id == vegetables.id
      assert Enum.at(counts, 1).food_id == fruit.id
    end
  end
end
