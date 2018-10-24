defmodule AheTrackerPete.Eating.Count do
  use Ecto.Schema
  import Ecto.Changeset

  schema "counts" do
    field(:count, :float)
    field(:user_id, :integer)
    field(:food_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(count, attrs) do
    count
    |> cast(attrs, [:count, :user_id, :food_id])
    |> validate_required([:count, :user_id, :food_id])
  end
end
