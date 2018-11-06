defmodule AheTrackerPete.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add(:name, :string)
      add(:priority, :integer)

      timestamps()
    end

    create(unique_index(:categories, [:priority]))
  end
end
