import Config

config :excms_account, Excms.Deps,
  deps: [
    :bamboo,
    :bamboo_smtp,
    :bcrypt_elixir,
    :ecto_sql,
    :gettext,
    :jason,
    :phoenix,
    :phoenix_ecto,
    :phoenix_html,
    :phoenix_pubsub,
    :plug_cowboy,
    :postgrex,
    :excms_core,
    :excms_account
  ]

config :excms_server, Excms.Deps,
  deps: [
    :bamboo,
    :bamboo_smtp,
    :bcrypt_elixir,
    :ecto_sql,
    :gettext,
    :jason,
    :phoenix,
    :phoenix_ecto,
    :phoenix_html,
    :phoenix_pubsub,
    :plug_cowboy,
    :postgrex,
    :phoenix_live_dashboard,
    :phoenix_live_reload,
    :telemetry_metrics,
    :telemetry_poller,
    :excms_core,
    :excms_account,
    :excms_server
  ]

if Path.expand("../deps/excms_core/apps/excms_core/config/config.exs", __DIR__) |> File.exists?(), do:
  import_config "../deps/excms_core/apps/excms_core/config/config.exs"

if Path.expand("../apps/excms_account/config/config.exs", __DIR__) |> File.exists?(), do:
  import_config "../apps/excms_account/config/config.exs"
