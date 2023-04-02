defmodule ExDbmigrate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ExDbmigrate.Config

  @impl true
  def start(_type, args) do
    repo = Config.repo()

    children =
      [
        {repo, args}
        # Starts a worker by calling: ExDbmigrate.Worker.start_link(arg)
        # {ExDbmigrate.Worker, arg}
      ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExDbmigrate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @version Mix.Project.config()[:version]
  def version, do: @version
end
