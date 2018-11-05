defmodule AheTrackerPete.Repo.Migrations.CreateFoods do
  use Ecto.Migration

  def change do
    create table(:foods) do
      add(:name, :string)
      add(:category, :string)
      add(:priority, :integer)

      timestamps()
    end

    create(unique_index(:foods, [:priority]))
  end
end
