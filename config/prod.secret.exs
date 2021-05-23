# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :excms_core, ExcmsCore.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :excms_server, ExcmsServer.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :excms_server, ExcmsServer.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.

config :excms_account, :email,
  service: ExcmsAccountWeb.Mailer,
  async_send: true

mailer_server = System.get_env("SMTP_SERVER") || raise "missing env SMTP_SERVER"
mailer_hostname = System.get_env("SMTP_HOSTNAME") || raise "missing env SMTP_HOSTNAME"
mailer_port = System.get_env("SMTP_PORT") || raise "missing env SMTP_PORT"
mailer_username = System.get_env("SMTP_USERNAME") || raise "missing env SMTP_USERNAME"
mailer_password = System.get_env("SMTP_PASSWORD") || raise "missing env SMTP_PASSWORD"

config :excms_account, ExcmsAccountWeb.Mailer,
  server: mailer_server,
  hostname: mailer_hostname,
  port: mailer_port,
  username: mailer_username,
  password: mailer_password
