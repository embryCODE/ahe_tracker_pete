defmodule AheTrackerPete.Repo.Migrations.ChangePasswordToPasswordHash do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:password_hash, :string, null: false)
      remove(:password)
    end
  end
end
