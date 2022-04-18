import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :humo, Humo.Repo,
  username: "postgres",
  password: "postgres",
  database: "humo_account_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :humo_account, HumoAccountWeb.Endpoint,
  http: [port: 4002],
  server: false

config :bcrypt_elixir, log_rounds: 4

config :humo, Humo.Authorizer,
  authorizer: Humo.Authorizer.Mock

# Print only warnings and errors during test
config :logger, level: :warn

config :humo_account, HumoAccountWeb.Mailer,
  sender: HumoAccountWeb.Mailer.SenderDummy,
  async: false
