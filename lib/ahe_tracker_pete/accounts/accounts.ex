defmodule AheTrackerPete.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias AheTrackerPete.Repo

  alias AheTrackerPete.Accounts.User

  alias AheTrackerPete.Eating
  alias AheTrackerPete.Eating.Count
  alias AheTrackerPete.Eating.Food

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns counts for the given user.

  ## Examples

      iex> list_counts_for_user(user)
      {:ok, [%Count{}, ...]}

  """
  def list_counts_for_user(%User{} = user) do
    Repo.all(from(c in Count, where: c.user_id == ^user.id))
  end

  @doc """
  Creates a count of zero for each food and this user.
  """
  def init_counts_for_user(%User{} = user) do
    foods = Eating.list_foods()

    foods
    |> Enum.each(fn food ->
      Eating.create_count(%{
        user_id: user.id,
        food_id: food.id,
        count: 0
      })
    end)
  end
end
