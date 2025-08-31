defmodule ExDbmigrate.Repo.Migrations.CreateVideosToProduct do
  use Ecto.Migration

  def change do

    create table(:catalog_videos_to_product) do
      add(:product_id, references(:catalog_products, type: :binary_id, on_delete: :nothing))
      add(:video_id, references(:catalog_videos, type: :binary_id, on_delete: :nothing))
    end
  end
end
