use Mix.Config

config :excms_account, Excms.Deps,
  deps: [
    :bamboo,
    :bamboo_smtp,
    :bcrypt_elixir,
    :ecto_sql,
    :ex_machina,
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
    :ex_machina,
    :gettext,
    :jason,
    :phoenix,
    :phoenix_ecto,
    :phoenix_html,
    :phoenix_pubsub,
    :plug_cowboy,
    :postgrex,
    :phoenix_live_dashboard,
    :telemetry_metrics,
    :telemetry_poller,
    :excms_core,
    :excms_account,
    :excms_server
  ]

import_config "../deps/excms_core/apps/excms_core/config/config.exs"
import_config "../apps/excms_account/config/config.exs"
