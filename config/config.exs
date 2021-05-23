# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

deps_dir = Path.join(__DIR__, "../deps/excms_deps/") |> Path.expand()

if File.exists?(deps_dir) do
  Path.join(deps_dir, "lib/excms_deps.ex") |> Code.require_file()
  for config <- ExcmsDeps.configs(), do: import_config(config)
end

# Configures the endpoint
config :excms_server, ExcmsServer.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "V0NX0EdWwTTziTVofQPzLnTmc+XYGIwYTWBoBAsudxzN15U8AuWrQNuvkT4tjs4p",
  render_errors: [view: ExcmsAccountWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExcmsAccount.PubSub,
  live_view: [signing_salt: "HHvyYCFk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :excms_account, ExcmsAccountWeb.Mailer,
  adapter: Bamboo.SMTPAdapter,
  tls: :if_available,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: true,
  retries: 3,
  no_mx_lookups: false,
  auth: :always

config :excms_account, ExcmsAccountWeb.AuthService,
  timeout_seconds: 3600 * 24,
  secret: "sKKlOpvwOwHg+cTLFO4byayYBUWEBGCJGjgGTjdRWYkTVPNGi9gnlYAmVCWo9mVnDhgT",
  salt: "JghkDhKAHTBDTVtbtdsOTtdsgtOPGqKSHvBtGHTDgh"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
