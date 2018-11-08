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
  Gets a single count by a certain user.

  """
  def get_count_for_user!(id, user_id), do: Repo.get_by!(Count, id: id, user_id: user_id)

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

  alias AheTrackerPete.Eating.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Create or update a category.

  """
  def create_or_update_category(category, id) do
    case Repo.get(Category, id) do
      nil -> %Category{id: id}
      category -> category
    end
    |> Category.changeset(category)
    |> Repo.insert_or_update()
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end
end
