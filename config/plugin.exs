# This file is responsible for configuring your plugin application
#
# This configuration can be partially overriden by plugin that has
# this application as dependency

# General application configuration
import Config

config :humo_account,
  ecto_repos: [Humo.Repo]

config :humo, :plugins,
  humo_account: %{
    title: "Accounts",
    dashboard_links: [
      %{title: "Users", route: :dashboard_humo_account_user_path, action: :index}
    ],
    account_links: [
      %{title: "Login", route: :humo_account_session_path, action: :new},
      %{title: "Profile", route: :humo_account_profile_user_path, action: :show},
      %{title: "Logout", route: :humo_account_session_path, action: :delete, method: :delete}
    ]
  }

config :humo, HumoWeb.PluginsRouter, humo_account: HumoAccountWeb.PluginRouter

config :humo, HumoWeb.BrowserPlugs, humo_account: [{HumoAccountWeb.AssignUserPlug, true}]

config :humo, Humo.Warehouse, humo_account: [HumoAccount.UsersService.User]

config :humo_account, HumoAccountWeb.Mailer,
  view: HumoAccountWeb.EmailView,
  layout: {HumoAccountWeb.EmailView, :layout}
