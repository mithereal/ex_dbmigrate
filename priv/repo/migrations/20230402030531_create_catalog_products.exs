defmodule ExDbmigrate.Repo.Migrations.CreateCatalogProducts do
  use Ecto.Migration

  def change do

    create table(:catalog_products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
