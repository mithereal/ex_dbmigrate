defmodule ExDbmigrate.Repo.Migrations.CreateCatalogVideos do
  use Ecto.Migration

  def change do
    create table(:catalog_videos_to_product) do
      add(:product_id, references(:catalog_products, on_delete: :nothing))
      add(:video_id, references(:catalog_videos, on_delete: :nothing))
    end
  end
end
