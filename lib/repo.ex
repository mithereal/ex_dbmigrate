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
end

defmodule ExDbmigrate.Repo.Null do
  use Ecto.Repo,
    otp_app: :ex_dbmigrate,
    adapter: Ecto.Adapters.Postgres

  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
