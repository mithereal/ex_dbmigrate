defmodule ExDbmigrate.Repo.Migrations.CreateCatalogVideos do
  use Ecto.Migration

  def change do

    create table(:catalog_videos, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :path, :string

      timestamps()
    end
  end
end
