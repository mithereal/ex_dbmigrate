defmodule ExDbmigrate.Repo.Migrations.CreateCatalogProducts do
  use Ecto.Migration

  def change do
    key_type = ExDbmigrate.Config.key_type(:migration)

    create table(:catalog_products, primary_key: false) do
      add :id, key_type, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
