defmodule AheTrackerPete.Repo.Migrations.AddDeleteAllToUserAssociations do
  use Ecto.Migration

  def change do
    alter table(:counts) do
      remove(:user_id)
      remove(:food_id)
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:food_id, references(:foods, on_delete: :delete_all))
    end
  end
end
