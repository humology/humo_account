import Config

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
      %{title: "Logout", route: :session_path, action: :delete, method: :delete}
    ]
  }

config :excms_core, ExcmsCoreWeb.PluginsRouter,
  excms_account: %{
    routers: [ExcmsAccountWeb.Routers.Root],
    cms_routers: [ExcmsAccountWeb.Routers.Cms]
  }

config :excms_core, ExcmsCoreWeb.BrowserPlugs,
  excms_account: [{ExcmsAccountWeb.AssignUserPlug, true}]

config :excms_core, ExcmsCore.Warehouse, excms_account: [ExcmsAccount.UsersService.User]

config :excms_account, ExcmsAccountWeb.Mailer,
  sender: ExcmsAccountWeb.Mailer.SenderDummy,
  async: true

config :excms_account, ExcmsAccountWeb.Mailer.VerifyEmail,
  renderer: ExcmsAccountWeb.Mailer.VerifyEmail

config :excms_account, ExcmsAccountWeb.Mailer.ResetPassword,
  renderer: ExcmsAccountWeb.Mailer.ResetPassword
