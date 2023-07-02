defmodule ExDbmigrate.Repo.Migrations.CreateCatalogMetas do
  use Ecto.Migration

  def change do
    key_type = ExDbmigrate.Config.key_type(:migration)
    ref_type = ExDbmigrate.Config.key_type()

    create table(:catalog_metas, primary_key: false) do
      add :id, key_type, primary_key: true
      add :key, :string
      add :data, :string
      add(:product_id, references(:catalog_products, type: ref_type, on_delete: :nothing))

      timestamps()
    end
  end
end
