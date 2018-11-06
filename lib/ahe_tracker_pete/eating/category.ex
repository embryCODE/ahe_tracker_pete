defmodule AheTrackerPete.Eating.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field(:name, :string)
    field(:priority, :integer)

    timestamps()

    has_many(:foods, AheTrackerPete.Eating.Food)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :priority])
    |> unique_constraint(:priority)
    |> validate_required([:name, :priority])
  end
end
