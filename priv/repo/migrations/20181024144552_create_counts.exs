defmodule AheTrackerPete.Repo.Migrations.CreateCounts do
  use Ecto.Migration

  def change do
    create table(:counts) do
      add(:user_id, references(:users))
      add(:food_id, references(:foods))
      add(:count, :float)

      timestamps()
    end

    create(unique_index(:counts, [:user_id, :food_id]))
  end
end
