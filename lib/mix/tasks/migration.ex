defmodule Mix.Tasks.ExDbmigrate.Gen.Migration do
  use Mix.Task

  @moduledoc """
    After configuring your default ecto repo in `:ecto_repos`
    Run mix ExDbmigrate to generates a migration.
  """

  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:ex_dbmigrate)
    Mix.shell().info("ExDbmigrate v#{Application.spec(:ex_dbmigrate, :vsn)}")

    ExDbmigrate.migration()
    |> Enum.join(", ")
  end

  def generate(args) do
    source = Path.join(Application.app_dir(:ex_dbmigrate, "/priv/"), "migration.exs")
    name = Keyword.fetch(args, :name)

    target = Path.join(File.cwd!(), "/priv/repo/migrations/#{timestamp()}_#{name}.exs")

    if !File.dir?(target) do
      File.mkdir_p("priv/repo/migrations/")
    end

    Mix.Generator.create_file(target, EEx.eval_file(source, args))
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
