defmodule Humo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:humo_account_users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :first_name, :text
      add :last_name, :text
      add :email, :text
      add :email_verified_at, :utc_datetime_usec
      add :password_hash, :text

      timestamps()
    end

    create unique_index(:humo_account_users, [:email])
  end
end
