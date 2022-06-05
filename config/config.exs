# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

if Path.expand("humo_#{Mix.env()}.exs", __DIR__) |> File.exists?(), do:
  import_config "humo_#{Mix.env()}.exs"

# Configures the endpoint
config :humo_account, HumoAccountWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: HumoAccountWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HumoAccount.PubSub,
  live_view: [signing_salt: "YsbwsVkA"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :humo_account, HumoAccountWeb.AuthService,
  timeout_seconds: 3600*24,
  secret: "sKKlOpvwOwHg+cTLFO4byayYBUWEBGCJGjgGTjdRWYkTVPNGi9gnlYAmVCWo9mVnDhgT",
  salt: "JghkDhKAHTBDTVtbtdsOTtdsgtOPGqKSHvBtGHTDgh"

config :humo_account, HumoAccountWeb.Mailer,
  adapter: Bamboo.SMTPAdapter,
  tls: :if_available,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: true,
  retries: 3,
  no_mx_lookups: false,
  auth: :always

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
