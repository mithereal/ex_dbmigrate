defmodule Mix.Tasks.ExDbmigrate.Gen.Modules do
  use Mix.Task

  @moduledoc """
    After configuring your default ecto repo in `:ecto_repos`
    Run mix ExDbmigrate to generates a html view.
  """

  def run(args) do
    {:ok, _} = Application.ensure_all_started(:ex_dbmigrate)
    Mix.shell().info("ExDbmigrate v#{Application.spec(:ex_dbmigrate, :vsn)}")

    ExDbmigrate.Module.generate_modules(ExDbmigrate.Repo, args)
  end
end
