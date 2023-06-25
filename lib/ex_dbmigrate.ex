defmodule ExDbmigrate do
  @moduledoc """
  Documentation for `ExDbmigrate`.
  """

  @repo ExDbmigrate.Config.repo()

    @doc """
  Generate migration from config.

  ## Examples

      iex> ExDbmigrate.migration()
      []

  """
  def migration() do
    results = fetch_results()

    Enum.map(results.rows, fn r ->
      fetch_table_data(r)
      |> generate_migration_command(r)
    end)
  end

  @doc """
  Generate schema from config.

  ## Examples

      iex> ExDbmigrate.schema()
      []

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
      []

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
      []

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
      []

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

  defp type_select(t) do
    case(t) do
      "character varying" -> "string"
      "timestamp without time zone" -> "naive_datetime"
      "timestamp with time zone" -> "utc_datetime"
      "USER-DEFINED" -> "any"
      data -> data
    end
  end
end
