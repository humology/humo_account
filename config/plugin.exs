import Config

# Configure Mix tasks and generators
config :humo_account,
  ecto_repos: [Humo.Repo]

config :humo, :plugins,
  humo_account: %{
    title: "Accounts",
    dashboard_links: [
      %{title: "Users", route: :dashboard_user_path, action: :index}
    ],
    account_links: [
      %{title: "Login", route: :session_path, action: :new},
      %{title: "Profile", route: :profile_user_path, action: :show},
      %{title: "Logout", route: :session_path, action: :delete, method: :delete}
    ]
  }

config :humo, HumoWeb.PluginsRouter,
  humo_account: %{
    routers: [HumoAccountWeb.Routers.Root],
    dashboard_routers: [HumoAccountWeb.Routers.Dashboard]
  }

config :humo, HumoWeb.BrowserPlugs,
  humo_account: [{HumoAccountWeb.AssignUserPlug, true}]

config :humo, Humo.Warehouse,
  humo_account: [HumoAccount.UsersService.User]

config :humo_account, HumoAccountWeb.Mailer,
  sender: HumoAccountWeb.Mailer.SenderDummy,
  async: true

config :humo_account, HumoAccountWeb.Mailer.VerifyEmail,
  renderer: HumoAccountWeb.Mailer.VerifyEmail

config :humo_account, HumoAccountWeb.Mailer.ResetPassword,
  renderer: HumoAccountWeb.Mailer.ResetPassword
