defmodule AheTrackerPete.Eating.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "foods" do
    field(:name, :string)
    field(:priority, :integer)

    timestamps()

    many_to_many(:users, AheTrackerPete.Accounts.User, join_through: AheTrackerPete.Eating.Count)
    belongs_to(:categories, AheTrackerPete.Eating.Category, foreign_key: :category_id)
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name, :priority, :category_id])
    |> unique_constraint(:priority)
    |> validate_required([:name, :priority, :category_id])
  end
end
