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
    postgres_query()
  end

  def mysql_query do
    import Ecto.Query, only: [from: 2]

    schema = Application.get_env(:ex_dbmigrate, :ecto_repos, :not_found)

    query =
      from(c in "INFORMATION_SCHEMA.COLUMNS",
        where: "TABLE_SCHEMA" == ^schema,
        select: c."COLUMN_NAME"
      )

    @repo.all(query)
  end

  def postgres_query do
    import Ecto.Query, only: [from: 2]

    query = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"

    results = Ecto.Adapters.SQL.query!(@repo, query, [])

    Enum.map(results.rows, fn r ->
      fetch_table_data(r)
    end)
  end

  defp fetch_table_data(r) do
    query =
      "SELECT column_name, is_nullable, data_type, ordinal_position, character_maximum_length FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = '#{r}'"

    Ecto.Adapters.SQL.query!(@repo, query, [])
  end
end
