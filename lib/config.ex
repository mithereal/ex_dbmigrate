defmodule ExDbmigrate.Config do
  @doc """
  Return value by key from config.exs file.
  """

  alias ExDbmigrate.InvalidConfigError

  def get(name, default \\ nil) do
    Application.get_env(:ex_dbmigrate, name, default)
  end

  def repo, do: List.first(Application.fetch_env!(:ex_dbmigrate, :ecto_repos))
  def repos, do: Application.fetch_env!(:ex_dbmigrate, :ecto_repos)

  @spec config() :: Keyword.t() | none()
  def config() do
    case Application.get_env(:ex_dbmigrate, :ecto_repos, :not_found) do
      :not_found ->
        raise InvalidConfigError, "ex_dbmigrate config not found"

      config ->
        if not Keyword.keyword?(config) do
          raise InvalidConfigError,
                "ex_dbmigrate config was found, but doesn't contain a keyword list."
        end

        config
    end
  end

  def key_type() do
    case Application.get_env(:ex_dbmigrate, repo())[:primary_key_type] do
      nil -> :integer
      _ -> :binary_id
    end
  end

  def key_type(:migration) do
    case Application.get_env(:ex_dbmigrate, repo())[:primary_key_type] do
      nil -> :integer
      _ -> :uuid
    end
  end
end
