import Config

config :excms_server, Excms.Deps,
  deps: [
    %{app: :excms_core, path: "../deps/excms_core"},
    %{app: :excms_account, path: "../"},
    %{app: :excms_server, path: "./"}
  ]

if Path.expand("../../deps/excms_core/config/plugin.exs", __DIR__) |> File.exists?(), do:
  import_config "../../deps/excms_core/config/plugin.exs"

if Path.expand("../../config/plugin.exs", __DIR__) |> File.exists?(), do:
  import_config "../../config/plugin.exs"
