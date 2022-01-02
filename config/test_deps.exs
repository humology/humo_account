import Config

config :excms_core, ExcmsCore,
  deps: [
    %{app: :excms_core, path: "deps/excms_core"},
    %{app: :excms_account, path: "./"}
  ],
  server_app: :excms_account

if Path.expand("../deps/excms_core/config/plugin.exs", __DIR__) |> File.exists?(), do:
  import_config "../deps/excms_core/config/plugin.exs"

if Path.expand("../config/plugin.exs", __DIR__) |> File.exists?(), do:
  import_config "../config/plugin.exs"
