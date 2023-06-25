defmodule ExDbmigrate.Repo.Migrations.CreateCatalogMetas do
  use Ecto.Migration

  def change do
    create table(:catalog_metas) do
      add :id, :uuid
      add :key, :string
      add :data, :string
      add(:product_id, references(:catalog_products, on_delete: :nothing))

      timestamps()
    end
  end
end
