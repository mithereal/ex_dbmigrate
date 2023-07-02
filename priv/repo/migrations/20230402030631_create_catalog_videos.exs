defmodule ExDbmigrate.Repo.Migrations.CreateCatalogVideos do
  use Ecto.Migration

  def change do
    key_type = ExDbmigrate.Config.key_type(:migration)

    create table(:catalog_videos, primary_key: false) do
      add :id, key_type, primary_key: true
      add :path, :string

      timestamps()
    end
  end
end
