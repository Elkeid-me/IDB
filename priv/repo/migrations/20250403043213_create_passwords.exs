defmodule Idb.Repo.Migrations.CreatePasswords do
  use Ecto.Migration

  def change do
    create table(:passwords) do
      add(:website, :string)
      add(:username, :string)
      add(:password, :string)
      add(:creator_id, references(:users))
      timestamps()
    end

    create(index(:passwords, [:creator_id]))
  end
end
