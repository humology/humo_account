# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

if Path.expand("humo_#{config_env()}.exs", __DIR__) |> File.exists?(),
  do: import_config("humo_#{config_env()}.exs")

# Configures Humo.Repo adapter
config :humo, Humo.Repo, adapter: Ecto.Adapters.Postgres

# Configures the endpoint
config :humo_account, HumoAccountWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: HumoAccountWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HumoAccount.PubSub,
  live_view: [signing_salt: "YsbwsVkA"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :humo_account, HumoAccountWeb.AuthService,
  timeout_seconds: 3600 * 24,
  secret: "sKKlOpvwOwHg+cTLFO4byayYBUWEBGCJGjgGTjdRWYkTVPNGi9gnlYAmVCWo9mVnDhgT",
  salt: "JghkDhKAHTBDTVtbtdsOTtdsgtOPGqKSHvBtGHTDgh"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
