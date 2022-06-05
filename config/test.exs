import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :humo, Humo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "humo_account_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :humo_account, HumoAccountWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "mUDAhXVs7lDlMk619QqT/DoYEwr1BDzD8i9aPghf37eksTk4X/O5sTZG5Dy/r4Y7",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :humo, Humo.Authorizer, authorizer: Humo.Authorizer.Mock

config :bcrypt_elixir, log_rounds: 4

config :humo_account, HumoAccountWeb.Mailer,
  sender: HumoAccountWeb.Mailer.SenderDummy,
  async: false
