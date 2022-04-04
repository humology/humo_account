import Config

# Configure Mix tasks and generators
config :excms_account,
  ecto_repos: [ExcmsCore.Repo]

config :excms_core, :plugins,
  excms_account: %{
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

config :excms_core, ExcmsCoreWeb.PluginsRouter,
  excms_account: %{
    routers: [ExcmsAccountWeb.Routers.Root],
    dashboard_routers: [ExcmsAccountWeb.Routers.Dashboard]
  }

config :excms_core, ExcmsCoreWeb.BrowserPlugs,
  excms_account: [{ExcmsAccountWeb.AssignUserPlug, true}]

config :excms_core, ExcmsCore.Warehouse,
  excms_account: [ExcmsAccount.UsersService.User]

config :excms_account, ExcmsAccountWeb.Mailer,
  sender: ExcmsAccountWeb.Mailer.SenderDummy,
  async: true

config :excms_account, ExcmsAccountWeb.Mailer.VerifyEmail,
  renderer: ExcmsAccountWeb.Mailer.VerifyEmail

config :excms_account, ExcmsAccountWeb.Mailer.ResetPassword,
  renderer: ExcmsAccountWeb.Mailer.ResetPassword
