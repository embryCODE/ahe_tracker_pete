defmodule AheTrackerPete.Eating.Count do
  use Ecto.Schema
  import Ecto.Changeset

  schema "counts" do
    field(:count, :float)

    timestamps()
  end

  @doc false
  def changeset(count, attrs) do
    count
    |> cast(attrs, [:count])
    |> validate_required([:count])
  end
end
