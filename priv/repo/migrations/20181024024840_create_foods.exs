defmodule AheTrackerPete.Repo.Migrations.CreateFoods do
  use Ecto.Migration

  def change do
    create table(:foods) do
      add(:name, :string)
      add(:category, :string)

      timestamps()
    end
  end
end
