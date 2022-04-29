import Config

config :humo, Humo,
  apps: [
    %{app: :humo, path: "deps/humo"},
    %{app: :humo_account, path: "./"}
  ],
  server_app: :humo_account

if Path.expand("../deps/humo/config/plugin.exs", __DIR__) |> File.exists?(), do:
  import_config "../deps/humo/config/plugin.exs"

if Path.expand("../config/plugin.exs", __DIR__) |> File.exists?(), do:
  import_config "../config/plugin.exs"
