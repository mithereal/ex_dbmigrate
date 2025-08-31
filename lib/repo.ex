defmodule ExDbmigrate.Repo do
  use Ecto.Repo,
    otp_app: :ex_dbmigrate,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Empty the Database Table
  """
  def truncate(schema) do
    table_name = schema.__schema__(:source)

    query("TRUNCATE #{table_name}", [])
  end

  defp list_tables(repo, schema_name \\ "public") do
    adapter = repo.__adapter__()
    query =
      case adapter do
        Ecto.Adapters.Postgres ->
          "SELECT tablename FROM pg_tables WHERE schemaname='#{schema_name}';"
        _ ->
          raise "Adapter not supported"
      end

    repo
    |> Ecto.Adapters.SQL.query!(query)
    |> case do
         %{rows: rows} -> List.flatten(rows)
       end
  end

  defp get_columns(repo, table) do
    adapter = repo.__adapter__()
    query =
      case adapter do
        Ecto.Adapters.Postgres ->
          """
          SELECT column_name, data_type
          FROM information_schema.columns
          WHERE table_name='#{table}';
          """
        _ ->
          raise "Adapter not supported"
      end

    repo
    |> Ecto.Adapters.SQL.query!(query)
    |> case do
         %{columns: cols, rows: rows} ->
           Enum.map(rows, fn row ->
             Enum.zip(cols, row) |> Enum.into(%{})
           end)
       end
  end
end

defmodule ExDbmigrate.Repo.Null do
  use Ecto.Repo,
    otp_app: :ex_dbmigrate,
    adapter: Ecto.Adapters.Postgres

  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
