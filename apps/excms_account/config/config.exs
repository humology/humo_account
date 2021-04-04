use Mix.Config

# Configure Mix tasks and generators
config :excms_account,
  ecto_repos: [ExcmsCore.Repo]

config :excms_core, :plugins,
  excms_account: %{
    title: "Accounts",
    cms_links: [
      %{title: "Users", route: :cms_user_path, action: :index}
    ],
    account_links: [
      %{title: "Profile", route: :profile_user_path, action: :show},
      %{title: "Logout", route: :session_path, action: :delete},
    ]
  }

config :excms_core, ExcmsCoreWeb.PluginsRouter,
  excms_account: %{
    routers: [ExcmsAccountWeb.Routers.Root],
    cms_routers: [ExcmsAccountWeb.Routers.Cms]
  }
