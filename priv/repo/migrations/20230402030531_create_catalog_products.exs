defmodule ExDbmigrate.Repo.Migrations.CreateCatalogProducts do
  use Ecto.Migration

  def change do
    create table(:catalog_products) do
      add :id, :uuid
      add :name, :string

      timestamps()
    end
  end
end
