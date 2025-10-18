defmodule ExDbmigrate do
  @moduledoc """
  Documentation for `ExDbmigrate`.
  """
  @repo ExDbmigrate.Repo
  @ignore ["information_schema", "pg_catalog"]

  import Exflect

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

      iex> ExDbmigrate.migration("public")
      ["mix phx.gen.migration CatalogMetas CatalogMeta catalog_metas key:string data:string product_id:uuid",
      "mix phx.gen.migration CatalogVideosToProducts CatalogVideosToProduct catalog_videos_to_product product_id:uuid video_id:uuid",
      "mix phx.gen.migration CatalogProducts CatalogProduct catalog_products name:string",
      "mix phx.gen.migration CatalogVideos CatalogVideo catalog_videos path:string"]

  """
  def migration(schema \\ "public", mode \\ :read, filename \\ "db_migrate") do
    results = fetch_results(schema)

    map =
      Enum.map(results.rows, fn r ->
        fetch_table_data(r)
        |> generate_migration_command(r)
      end)

    case mode do
      :read -> map
      :write -> map |> write_file(filename)
    end
  end

  @doc """
  Generate migration from config.

  ## Examples

      iex> ExDbmigrate.migration_relations()
      ["mix phx.gen.schema CatalogMetas.CatalogMeta catalog_metas product_id:references:catalog_products",
      "mix phx.gen.schema CatalogVideosToProducts.CatalogVideosToProduct catalog_videos_to_product product_id:references:catalog_products video_id:references:catalog_videos",
      "mix phx.gen.schema CatalogProducts.CatalogProduct catalog_products ",
      "mix phx.gen.schema CatalogVideos.CatalogVideo catalog_videos "]

  """
  def migration_relations(schema \\ "public", mode \\ :read, filename \\ "db_migrate") do
    results = fetch_results(schema)

    map =
      Enum.map(results.rows, fn r ->
        list_foreign_keys(r)
        |> generate_migration_relations_command(r)
      end)

    case mode do
      :read -> map
      :write -> map |> write_file(filename)
    end
  end

  @doc """
  Generate schema from config.

  ## Examples

      iex> ExDbmigrate.schema()
      ["mix phx.gen.schema CatalogMetas.CatalogMeta catalog_metas key:string data:string product_id:uuid --no-migration",
      "mix phx.gen.schema CatalogVideosToProducts.CatalogVideosToProduct catalog_videos_to_product product_id:uuid video_id:uuid --no-migration",
      "mix phx.gen.schema CatalogProducts.CatalogProduct catalog_products name:string --no-migration",
      "mix phx.gen.schema CatalogVideos.CatalogVideo catalog_videos path:string --no-migration"]

  """
  def schema(schema \\ "public", mode \\ :read, filename \\ "db_migrate") do
    results = fetch_results(schema)

    map =
      Enum.map(results.rows, fn r ->
        fetch_table_data(r)
        |> generate_schemas_command(r)
      end)

    case mode do
      :read -> map
      :write -> map |> write_file(filename)
    end
  end

  @doc """
  Generate schema from config.

  ## Examples

      iex> ExDbmigrate.html()
      ["mix phx.gen.html CatalogMetas CatalogMeta catalog_metas key:string data:string product_id:uuid",
       "mix phx.gen.html CatalogVideosToProducts CatalogVideosToProduct catalog_videos_to_product product_id:uuid video_id:uuid",
       "mix phx.gen.html CatalogProducts CatalogProduct catalog_products name:string",
       "mix phx.gen.html CatalogVideos CatalogVideo catalog_videos path:string"
      ]

  """
  def html(schema \\ "public", mode \\ :read, filename \\ "db_migrate") do
    results = fetch_results(schema)

    map =
      Enum.map(results.rows, fn r ->
        fetch_table_data(r)
        |> generate_htmls_command(r)
      end)

    case mode do
      :read -> map
      :write -> map |> write_file(filename)
    end
  end

  @doc """
  Generate schema from config.

  ## Examples

      iex> ExDbmigrate.json()
      ["mix phx.gen.json CatalogMetas CatalogMeta catalog_metas key:string data:string product_id:uuid",
      "mix phx.gen.json CatalogVideosToProducts CatalogVideosToProduct catalog_videos_to_product product_id:uuid video_id:uuid",
      "mix phx.gen.json CatalogProducts CatalogProduct catalog_products name:string",
      "mix phx.gen.json CatalogVideos CatalogVideo catalog_videos path:string"]

  """
  def json(schema \\ "public", mode \\ :read, filename \\ "db_migrate") do
    results = fetch_results(schema)

    map =
      Enum.map(results.rows, fn r ->
        fetch_table_data(r)
        |> generate_jsons_command(r)
      end)

    case mode do
      :read -> map
      :write -> map |> write_file(filename)
    end
  end

  @doc """
  Generate schema from config.

  ## Examples

      iex> ExDbmigrate.live()
      ["mix phx.gen.live CatalogMetas CatalogMeta catalog_metas key:string data:string product_id:uuid",
      "mix phx.gen.live CatalogVideosToProducts CatalogVideosToProduct catalog_videos_to_product product_id:uuid video_id:uuid",
      "mix phx.gen.live CatalogProducts CatalogProduct catalog_products name:string",
      "mix phx.gen.live CatalogVideos CatalogVideo catalog_videos path:string"]

  """
  def live(schema \\ "public", mode \\ :read, filename \\ "db_migrate") do
    results = fetch_results(schema)

    map =
      Enum.map(results.rows, fn r ->
        fetch_table_data(r)
        |> generate_lives_command(r)
      end)

    case mode do
      :read -> map
      :write -> map |> write_file(filename)
    end
  end

  def fetch_table_schemas(ignore \\ @ignore) do
    query = "SELECT schema_name
      FROM information_schema.schemata;"

    Ecto.Adapters.SQL.query!(@repo, query, []) |> Enum.reject(fn x -> Enum.member?(ignore, x) end)
  end

  def fetch_results(schema \\ "public") do
    query =
      "SELECT table_name FROM information_schema.tables WHERE table_schema = '#{schema}' and table_name != 'schema_migrations';"

    Ecto.Adapters.SQL.query!(@repo, query, [])
  end

  def fetch_table_data(r, schema \\ "public") do
    query =
      "SELECT column_name, is_nullable, data_type, ordinal_position, character_maximum_length FROM information_schema.columns
WHERE table_schema = '#{schema}'
  AND table_name   = '#{r}'"

    Ecto.Adapters.SQL.query!(@repo, query, [])
  end

  def generate_jsons_command(data, [migration_name]) do
    migration_string = migration_string(data)

    migration_module = migration_module(migration_name)

    table = table_name(migration_name)

    module_name = migration_module |> singularize()

    module = migration_module |> pluralize()

    "mix phx.gen.json #{module} #{module_name} #{table} #{migration_string}"
  end

  def generate_lives_command(data, [migration_name]) do
    migration_string = migration_string(data)

    migration_module = migration_module(migration_name)

    table = table_name(migration_name)

    module_name = migration_module |> singularize()

    module = migration_module |> pluralize()

    "mix phx.gen.live #{module} #{module_name} #{table} #{migration_string}"
  end

  def migration_module(data) do
    String.split(data, "_")
    |> Enum.map(fn x -> String.capitalize(x) end)
    |> Enum.join("")
    |> String.trim()
  end

  def migration_string(data) do
    data.rows
    |> Enum.map(fn [id, _is_null, type, _position, _max_length] ->
      unless id == "id" || id == "inserted_at" || id == "updated_at" do
        type = type_select(type)
        "#{id}:#{type}"
      end
    end)
    |> Enum.join(" ")
    |> String.trim()
  end

  def table_name(migration_name) do
    migration_name

    String.split(migration_name, "_")
    |> Enum.map(fn x -> String.downcase(x) end)
    |> Enum.join("_")
    |> String.trim()
  end

  def generate_htmls_command(data, [migration_name]) do
    migration_string = migration_string(data)

    migration_module = migration_module(migration_name)

    table = table_name(migration_name)

    module_name = migration_module |> singularize()

    module = migration_module |> pluralize()

    "mix phx.gen.html #{module} #{module_name} #{table} #{migration_string}"
  end

  def generate_migration_command(data, [migration_name]) do
    migration_string = migration_string(data)

    migration_module = migration_module(migration_name)

    table = table_name(migration_name)

    module_name = migration_module |> singularize()

    module = migration_module |> pluralize()

    "mix phx.gen.migration #{module} #{module_name} #{table} #{migration_string}"
  end

  def generate_migration_relations_command(fk_data, [migration_name]) do
    migration_string =
      fk_data
      |> Enum.map(fn map ->
        "#{map.column_name}:references:#{map.foreign_table_name}"
      end)
      |> Enum.join(" ")
      |> String.trim()

    migration_module = migration_module(migration_name)

    table = table_name(migration_name)

    module_name = migration_module |> singularize()

    module = migration_module |> pluralize()

    migration_module = migration_module <> "Relations"

    migration_name = String.downcase(migration_name <> "relations")

    "mix phx.gen.schema #{module}.#{module_name} #{table} #{migration_string}"
  end

  def generate_schema_relations_command(fk_data, [migration_name]) do
    migration_string =
      fk_data
      |> Enum.map(fn map ->
        "#{map.column_name}:references:#{map.foreign_table_name}"
      end)
      |> Enum.join(" ")
      |> String.trim()

    migration_module = migration_module(migration_name)

    table = table_name(migration_name)

    module_name = migration_module |> singularize()

    module = migration_module |> pluralize()

    migration_module = migration_module <> "Relations"

    module_name = String.downcase(module_name <> "relations")

    "mix phx.gen.schema #{module}.#{module_name} #{table} #{migration_string}"
  end

  def generate_schemas_command(data, [migration_name]) do
    migration_string = migration_string(data)

    migration_module = migration_module(migration_name)

    table = table_name(migration_name)

    module_name = migration_module |> singularize()

    module = migration_module |> pluralize()

    "mix phx.gen.schema #{module}.#{module_name} #{table} #{migration_string} --no-migration"
  end

  def type_select(t) do
    case(t) do
      "character varying" -> "string"
      "timestamp without time zone" -> "naive_datetime"
      "timestamp with time zone" -> "utc_datetime"
      "USER-DEFINED" -> "map"
      "jsonb" -> "map"
      "ARRAY" -> "array:string"
      "any" -> "string"
      nil -> "string"
      data -> data
    end
  end

  def write_file(data, file \\ "db_migrate") do
    target = String.split(file, "/")

    if is_list(target) do
      target = case Enum.count(target) do
        1 ->
          Path.join(File.cwd!(), "/priv/#{file}")

        0 ->
          Path.join(File.cwd!(), "/priv/db_migrate.txt")

        _ ->
          filename = "#{timestamp()}_#{List.last(target)}"
          Path.join(File.cwd!(), "/priv/#{filename}")
      end

      data = Enum.join(data, "\n")
      target |> File.write(data)
    else
      Path.join(File.cwd!(), "/priv/#{timestamp()}_#{file}") |> File.write(data)
    end
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
