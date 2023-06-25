defmodule ExDbmigrate.Repo.Migrations.CreateCatalogVideos do
  use Ecto.Migration

  def change do
    create table(:catalog_videos) do
      add :id, :uuid
      add :path, :string

      timestamps()
    end
  end
end
