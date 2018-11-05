defmodule AheTrackerPete.Eating do
  @moduledoc """
  The Eating context.
  """

  import Ecto.Query, warn: false
  alias AheTrackerPete.Repo

  alias AheTrackerPete.Eating.Food
  alias AheTrackerPete.Eating.Count

  @doc """
  Returns the list of foods.

  ## Examples

      iex> list_foods()
      [%Food{}, ...]

  """
  def list_foods do
    Repo.all(Food)
  end

  @doc """
  Gets a single food.

  Raises `Ecto.NoResultsError` if the Food does not exist.

  ## Examples

      iex> get_food!(123)
      %Food{}

      iex> get_food!(456)
      ** (Ecto.NoResultsError)

  """
  def get_food!(id), do: Repo.get!(Food, id)

  @doc """
  Creates a food.

  ## Examples

      iex> create_food(%{field: value})
      {:ok, %Food{}}

      iex> create_food(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_food(attrs \\ %{}) do
    %Food{}
    |> Food.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a food.

  ## Examples

      iex> update_food(food, %{field: new_value})
      {:ok, %Food{}}

      iex> update_food(food, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_food(%Food{} = food, attrs) do
    food
    |> Food.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Create or update a food.

  """
  def create_or_update_food(food, id) do
    case Repo.get(Food, id) do
      nil -> %Food{id: id}
      food -> food
    end
    |> Food.changeset(food)
    |> Repo.insert_or_update()
  end

  @doc """
  Deletes a Food.

  ## Examples

      iex> delete_food(food)
      {:ok, %Food{}}

      iex> delete_food(food)
      {:error, %Ecto.Changeset{}}

  """
  def delete_food(%Food{} = food) do
    Repo.delete(food)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking food changes.

  ## Examples

      iex> change_food(food)
      %Ecto.Changeset{source: %Food{}}

  """
  def change_food(%Food{} = food) do
    Food.changeset(food, %{})
  end

  @doc """
  Returns the list of counts.

  ## Examples

      iex> list_counts()
      [%Count{}, ...]

  """
  def list_counts do
    Repo.all(Count)
  end

  @doc """
  Gets a single count.

  Raises `Ecto.NoResultsError` if the Count does not exist.

  ## Examples

      iex> get_count!(123)
      %Count{}

      iex> get_count!(456)
      ** (Ecto.NoResultsError)

  """
  def get_count!(id), do: Repo.get!(Count, id)

  @doc """
  Creates a count.

  ## Examples

      iex> create_count(%{field: value})
      {:ok, %Count{}}

      iex> create_count(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_count(attrs \\ %{}) do
    %Count{}
    |> Count.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a count.

  ## Examples

      iex> update_count(count, %{field: new_value})
      {:ok, %Count{}}

      iex> update_count(count, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_count(%Count{} = count, attrs) do
    count
    |> Count.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Count.

  ## Examples

      iex> delete_count(count)
      {:ok, %Count{}}

      iex> delete_count(count)
      {:error, %Ecto.Changeset{}}

  """
  def delete_count(%Count{} = count) do
    Repo.delete(count)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking count changes.

  ## Examples

      iex> change_count(count)
      %Ecto.Changeset{source: %Count{}}

  """
  def change_count(%Count{} = count) do
    Count.changeset(count, %{})
  end
end
