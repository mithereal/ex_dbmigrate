defmodule Mix.Tasks.ExDbmigrate.Gen.Migtation do
  use Mix.Task

  @moduledoc """
    After configuring your default ecto repo in `:ecto_repos`
    Run mix ExDbmigrate to generates a migration.
  """

  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:ex_dbmigrate)
    Mix.shell().info("ExDbmigrate v#{Application.spec(:ex_dbmigrate, :vsn)}")

    ExDbmigrate.migration()
    |> Enum.map(fn x ->
      IO.inspect(x)
    end)
  end
end
