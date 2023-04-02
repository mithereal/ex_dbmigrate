defmodule ExDbmigrate do
  @moduledoc """
  Documentation for `ExDbmigrate`.
  """

  @repo ExDbmigrate.Config.repo()

  @doc """
  Generate migration from config.

  ## Examples

      iex> ExDbmigrate.generate()
      []

  """
  def generate() do
    fetch_tables()
  end

  def generate_args() do
    fetch_tables(false)
  end

  def fetch_tables(command \\ false) do
    query =
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' and table_name != 'schema_migrations';"

    results = Ecto.Adapters.SQL.query!(@repo, query, [])

    Enum.map(results.rows, fn r ->
      fetch_table_data(r)
      |> generate_migration_command(r, command)
    end)
  end

  def fetch_table_data(r) do
    query =
      "SELECT column_name, is_nullable, data_type, ordinal_position, character_maximum_length FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = '#{r}'"

    Ecto.Adapters.SQL.query!(@repo, query, [])
  end

  def generate_migration_command(data, migration_name, command) do
    migration_string =
      data.rows
      |> Enum.map(fn [id, _is_null, type, _position, _max_length] ->
        type = type_select(type)
        "#{id}:#{type}"
      end)
      |> Enum.join(" ")

    case command do
      true -> "mix ecto.gen.migration #{migration_name} #{migration_string}"
      false -> "ecto.gen.migration #{migration_name} #{migration_string}"
    end
  end

  defp type_select(t) do
    case(t) do
      "character varying" -> "string"
      "USER-DEFINED" -> "any"
      data -> data
    end
  end
end
