import Config
# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :ex_dbmigrate, :ecto_repos, [ExDbmigrate.Repo]

config :ex_dbmigrate, ExDbmigrate.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex_dbmigrate",
  hostname: "localhost",
  port: 55432,
  pool_size: 10,
  primary_key_type: :uuid
