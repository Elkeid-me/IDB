defmodule Idb.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string)
      add(:password_hashed, :binary)
      add(:salt, :binary)
      timestamps()
    end

    create(unique_index(:users, [:username]))
  end
end
