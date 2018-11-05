defmodule AheTrackerPete.Eating.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "foods" do
    field(:category, :string)
    field(:name, :string)
    field(:priority, :integer)

    timestamps()

    many_to_many(:users, AheTrackerPete.Accounts.User, join_through: AheTrackerPete.Eating.Count)
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name, :category, :priority])
    |> unique_constraint(:priority)
    |> validate_required([:name, :category, :priority])
  end
end
