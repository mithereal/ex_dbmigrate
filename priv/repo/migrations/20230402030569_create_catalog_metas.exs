defmodule ExDbmigrate.Repo.Migrations.CreateCatalogMetas do
  use Ecto.Migration

  def change do

    create table(:catalog_metas, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :key, :string
      add :data, :string
      add(:product_id, references(:catalog_products, type: :binary_id, on_delete: :nothing))

      timestamps()
    end
  end
end
