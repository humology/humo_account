defmodule HumoAccountWeb.PluginRouter do
  @moduledoc false

  def root() do
    quote location: :keep do
      pipeline :humo_account_require_authentication do
        plug HumoAccountWeb.RequireAuthenticationPlug
      end

      scope "/", HumoAccountWeb do
        get "/login", SessionController, :new
        post "/login", SessionController, :create
        delete "/logout", SessionController, :delete

        get "/signup", SignupController, :new
        post "/signup", SignupController, :create
        get "/verify_email", VerifyEmailController, :index
        get "/verify_email/:token", VerifyEmailController, :edit
        get "/reset_password", ResetPasswordController, :new
        post "/reset_password", ResetPasswordController, :create
        get "/reset_password/:token", ResetPasswordController, :edit
        patch "/reset_password/:token", ResetPasswordController, :update
      end

      scope "/", HumoAccountWeb do
        pipe_through :humo_account_require_authentication

        scope "/profile", Profile, as: :profile do
          resources "/", UserController, only: [:show, :edit, :update], singleton: true
          resources "/email", UserEmailController, only: [:edit, :update], singleton: true
          resources "/password", UserPasswordController, only: [:edit, :update], singleton: true
        end
      end
    end
  end

  def dashboard() do
    quote location: :keep do
      resources "/users", HumoAccountWeb.Dashboard.UserController, except: [:new, :create]
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
