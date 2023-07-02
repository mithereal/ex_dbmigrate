defmodule ExDbmigrate.Repo.Migrations.CreateVideosToProduct do
  use Ecto.Migration

  def change do

    ref_type = ExDbmigrate.Config.key_type()

    create table(:catalog_videos_to_product) do
      add(:product_id, references(:catalog_products, type: ref_type, on_delete: :nothing))
      add(:video_id, references(:catalog_videos, type: ref_type, on_delete: :nothing))
    end
  end
end
