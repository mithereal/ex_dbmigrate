defmodule ExDbmigrate.MixProject do
  use Mix.Project
  @version "1.1.3"
  @source_url "https://github.com/mithereal/ExDbmigrate"

  def project do
    [
      app: :ex_dbmigrate,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs(),
      aliases: aliases(),
      name: "ex_dbmigrate",
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExDbmigrate.Application, []}
    ]
  end

  defp description do
    "Create Db Migrations from Pre-Existing Database."
  end

  defp package do
    # These are the default files included in the package
    [
      name: :ex_dbmigrate,
      files: ["lib", "priv", "mix.exs", "README*"],
      maintainers: ["Jason Clark"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/mithereal/ex_dbmigrate"}
    ]
  end

  defp docs do
    [
      main: "ExDbmigrate",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end

  defp aliases do
    [
      c: "compile",
      test: [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "run priv/seeds.exs",
        "test"
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:postgrex, ">= 0.0.0"},
      {:myxql, ">= 0.0.0"},
      {:ecto, "~> 3.5"},
      {:ecto_sql, "~> 3.5"},
      {:phoenix, "~> 1.7"},
      {:exflect, "1.0.0"}
    ]
  end
end
