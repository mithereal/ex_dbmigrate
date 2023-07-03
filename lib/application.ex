defmodule ExDbmigrate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ExDbmigrate.Config

  @impl true
  def start(_type, args) do
    repo = Config.repo()

    children = [
      {repo, args},
      # Starts a worker by calling: ExDbmigrate.Worker.start_link(arg)
      {Registry, keys: :unique, name: :tables},
      {ExDbmigrate.Table.Supervisor, args}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExDbmigrate.Supervisor]

    Supervisor.start_link(children, opts)
    |> load()
  end

  @version Mix.Project.config()[:version]
  def version, do: @version

  def load(params) do
    results = ExDbmigrate.fetch_results()

    tasks = Enum.map(results.rows, fn r ->
      Task.async(fn -> ExDbmigrate.Table.Supervisor.start(r) end)

    end)

    Task.await_many(tasks)

    Enum.map(results.rows, fn r ->
      List.first(r)
      |> ExDbmigrate.Table.Server.send_incoming_links()
    end)

    params
  end
end
