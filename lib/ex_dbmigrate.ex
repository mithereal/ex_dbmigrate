defmodule ExDbmigrate do
  @moduledoc """
  Documentation for `ExDbmigrate`.
  """

  @repo ExDbmigrate.Config.repo()

  @doc """
  List the foreign keys for specified table.

  ## Examples

      iex> ExDbmigrate.list_foreign_keys("catalog_metas")
      [%{column_name: "product_id", constraint_name: "catalog_metas_product_id_fkey", foreign_column_name: "id", foreign_table_name: "catalog_products", foreign_table_schema: "public", table_name: "catalog_metas", table_schema: "public"}
      ]

  """
  def list_foreign_keys(table) do
    query = "
SELECT
    tc.table_schema,
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name='#{table}';
"
    results = Ecto.Adapters.SQL.query!(@repo, query, [])

    Enum.map(results.rows, fn rows ->
      %{
        table_schema: List.first(rows),
        constraint_name: Enum.at(rows, 1),
        table_name: Enum.at(rows, 2),
        column_name: Enum.at(rows, 3),
        foreign_table_schema: Enum.at(rows, 4),
        foreign_table_name: Enum.at(rows, 5),
        foreign_column_name: List.last(rows)
      }
    end)
  end

  @doc """
  Generate migration from config.

  ## Examples

      iex> ExDbmigrate.migration()
      ["mix phx.gen.migration CatalogMetas catalog_metas  key:string data:string product_id:integer inserted_at:naive_datetime updated_at:naive_datetime",
        "mix phx.gen.migration CatalogVideosToProduct catalog_videos_to_product  product_id:integer video_id:integer",
        "mix phx.gen.migration CatalogProducts catalog_products  name:string inserted_at:naive_datetime updated_at:naive_datetime",
        "mix phx.gen.migration CatalogVideos catalog_videos  path:string inserted_at:naive_datetime updated_at:naive_datetime"
      ]

  """
  def migration() do
    results = fetch_results()

    Enum.map(results.rows, fn r ->
      fetch_table_data(r)
      |> generate_migration_command(r)
    end)
  end

  @doc """
  Generate migration from config.

  ## Examples

      iex> ExDbmigrate.migration_relations()
      ["mix phx.gen.migration CatalogMetasRelations catalog_metasrelations product_id:references:catalog_products",
       "mix phx.gen.migration CatalogVideosToProductRelations catalog_videos_to_productrelations product_id:references:catalog_products video_id:references:catalog_videos",
       "mix phx.gen.migration CatalogProductsRelations catalog_productsrelations ",
       "mix phx.gen.migration CatalogVideosRelations catalog_videosrelations "
      ]

  """
  def migration_relations() do
    results = fetch_results()

    Enum.map(results.rows, fn r ->
      list_foreign_keys(r)
      |> generate_migration_relations_command(r)
    end)
  end

  @doc """
  Generate schema from config.

  ## Examples

      iex> ExDbmigrate.schema()
      ["mix phx.gen.schema CatalogMetas catalog_metas  key:string data:string product_id:integer inserted_at:naive_datetime updated_at:naive_datetime --no-migration",
       "mix phx.gen.schema CatalogVideosToProduct catalog_videos_to_product  product_id:integer video_id:integer --no-migration",
       "mix phx.gen.schema CatalogProducts catalog_products  name:string inserted_at:naive_datetime updated_at:naive_datetime --no-migration",
       "mix phx.gen.schema CatalogVideos catalog_videos  path:string inserted_at:naive_datetime updated_at:naive_datetime --no-migration"
      ]

  """
  def schema() do
    results = fetch_results()

    Enum.map(results.rows, fn r ->
      fetch_table_data(r)
      |> generate_schemas_command(r)
    end)
  end

  @doc """
  Generate schema from config.

  ## Examples

      iex> ExDbmigrate.html()
      ["mix phx.gen.html CatalogMetas catalog_metas  key:string data:string product_id:integer inserted_at:naive_datetime updated_at:naive_datetime",
       "mix phx.gen.html CatalogVideosToProduct catalog_videos_to_product  product_id:integer video_id:integer",
       "mix phx.gen.html CatalogProducts catalog_products  name:string inserted_at:naive_datetime updated_at:naive_datetime",
       "mix phx.gen.html CatalogVideos catalog_videos  path:string inserted_at:naive_datetime updated_at:naive_datetime"
      ]

  """
  def html() do
    results = fetch_results()

    Enum.map(results.rows, fn r ->
      fetch_table_data(r)
      |> generate_htmls_command(r)
    end)
  end

  @doc """
  Generate schema from config.

  ## Examples

      iex> ExDbmigrate.json()
      ["mix phx.gen.json CatalogMetas catalog_metas  key:string data:string product_id:integer inserted_at:naive_datetime updated_at:naive_datetime",
       "mix phx.gen.json CatalogVideosToProduct catalog_videos_to_product  product_id:integer video_id:integer",
       "mix phx.gen.json CatalogProducts catalog_products  name:string inserted_at:naive_datetime updated_at:naive_datetime",
       "mix phx.gen.json CatalogVideos catalog_videos  path:string inserted_at:naive_datetime updated_at:naive_datetime"
      ]

  """
  def json() do
    results = fetch_results()

    Enum.map(results.rows, fn r ->
      fetch_table_data(r)
      |> generate_jsons_command(r)
    end)
  end

  @doc """
  Generate schema from config.

  ## Examples

      iex> ExDbmigrate.live()
      ["mix phx.gen.live CatalogMetas catalog_metas  key:string data:string product_id:integer inserted_at:naive_datetime updated_at:naive_datetime",
       "mix phx.gen.live CatalogVideosToProduct catalog_videos_to_product  product_id:integer video_id:integer",
       "mix phx.gen.live CatalogProducts catalog_products  name:string inserted_at:naive_datetime updated_at:naive_datetime",
       "mix phx.gen.live CatalogVideos catalog_videos  path:string inserted_at:naive_datetime updated_at:naive_datetime"
      ]

  """
  def live() do
    results = fetch_results()

    Enum.map(results.rows, fn r ->
      fetch_table_data(r)
      |> generate_lives_command(r)
    end)
  end

  def fetch_results() do
    query =
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' and table_name != 'schema_migrations';"

    Ecto.Adapters.SQL.query!(@repo, query, [])
  end

  def fetch_table_data(r) do
    query =
      "SELECT column_name, is_nullable, data_type, ordinal_position, character_maximum_length FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = '#{r}'"

    Ecto.Adapters.SQL.query!(@repo, query, [])
  end

  def generate_jsons_command(data, [migration_name]) do
    migration_string =
      data.rows
      |> Enum.map(fn [id, _is_null, type, _position, _max_length] ->
        unless id == "id" do
          type = type_select(type)
          "#{id}:#{type}"
        end
      end)
      |> Enum.join(" ")

    migration_module =
      String.split(migration_name, "_")
      |> Enum.map(fn x -> String.capitalize(x) end)
      |> Enum.join("")

    "mix phx.gen.json #{migration_module} #{migration_name} #{migration_string}"
  end

  def generate_lives_command(data, [migration_name]) do
    migration_string =
      data.rows
      |> Enum.map(fn [id, _is_null, type, _position, _max_length] ->
        unless id == "id" do
          type = type_select(type)
          "#{id}:#{type}"
        end
      end)
      |> Enum.join(" ")

    migration_module =
      String.split(migration_name, "_")
      |> Enum.map(fn x -> String.capitalize(x) end)
      |> Enum.join("")

    "mix phx.gen.live #{migration_module} #{migration_name} #{migration_string}"
  end

  def generate_htmls_command(data, [migration_name]) do
    migration_string =
      data.rows
      |> Enum.map(fn [id, _is_null, type, _position, _max_length] ->
        unless id == "id" do
          type = type_select(type)
          "#{id}:#{type}"
        end
      end)
      |> Enum.join(" ")

    migration_module =
      String.split(migration_name, "_")
      |> Enum.map(fn x -> String.capitalize(x) end)
      |> Enum.join("")

    "mix phx.gen.html #{migration_module} #{migration_name} #{migration_string}"
  end

  def generate_migration_command(data, [migration_name]) do
    migration_string =
      data.rows
      |> Enum.map(fn [id, _is_null, type, _position, _max_length] ->
        unless id == "id" do
          type = type_select(type)
          "#{id}:#{type}"
        end
      end)
      |> Enum.join(" ")

    migration_module =
      String.split(migration_name, "_")
      |> Enum.map(fn x -> String.capitalize(x) end)
      |> Enum.join("")

    "mix phx.gen.migration #{migration_module} #{migration_name} #{migration_string}"
  end

  def generate_migration_relations_command(fk_data, [migration_name]) do
    migration_string =
      fk_data
      |> Enum.map(fn map ->
        "#{map.column_name}:references:#{map.foreign_table_name}"
      end)
      |> Enum.join(" ")

    migration_module =
      String.split(migration_name, "_")
      |> Enum.map(fn x -> String.capitalize(x) end)
      |> Enum.join("")

    migration_module = migration_module <> "Relations"

    migration_name = migration_name <> "relations"

    "mix phx.gen.migration #{migration_module} #{migration_name} #{migration_string}"
  end

  def generate_schemas_command(data, [migration_name]) do
    migration_string =
      data.rows
      |> Enum.map(fn [id, _is_null, type, _position, _max_length] ->
        unless id == "id" do
          type = type_select(type)
          "#{id}:#{type}"
        end
      end)
      |> Enum.join(" ")

    migration_module =
      String.split(migration_name, "_")
      |> Enum.map(fn x -> String.capitalize(x) end)
      |> Enum.join("")

    "mix phx.gen.schema #{migration_module} #{migration_name} #{migration_string} --no-migration"
  end

  def type_select(t) do
    case(t) do
      "character varying" -> "string"
      "timestamp without time zone" -> "naive_datetime"
      "timestamp with time zone" -> "utc_datetime"
      "USER-DEFINED" -> "any"
      nil -> "string"
      data -> data
    end
  end
end
