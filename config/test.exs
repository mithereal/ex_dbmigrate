import Config
# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :ex_catalog, ExDbmigrate.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex_dbmigrate",
  hostname: "localhost",
  port: 5432,
  pool_size: 10
