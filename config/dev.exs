use Mix.Config

# Configure your database
config :excms_core, ExcmsCore.Repo,
  username: "postgres",
  password: "postgres",
  database: "excms_account_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :excms_server, ExcmsServer.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/excms_account/assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :excms_server, ExcmsServer.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/excms_account_web/(live|views)/.*(ex)$",
      ~r"lib/excms_account_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

mailer_server = System.get_env("DEV_SMTP_SERVER") || raise "missing env DEV_SMTP_SERVER"
mailer_hostname = System.get_env("DEV_SMTP_HOSTNAME") || raise "missing env DEV_SMTP_HOSTNAME"
mailer_port = System.get_env("DEV_SMTP_PORT") || raise "missing env DEV_SMTP_PORT"
mailer_username = System.get_env("DEV_SMTP_USERNAME") || raise "missing env DEV_SMTP_USERNAME"
mailer_password = System.get_env("DEV_SMTP_PASSWORD") || raise "missing env DEV_SMTP_PASSWORD"

config :excms_account, ExcmsAccountWeb.Mailer,
  sender: ExcmsAccountWeb.Mailer.Sender,
  server: mailer_server,
  hostname: mailer_hostname,
  port: mailer_port,
  username: mailer_username,
  password: mailer_password
