defmodule HumoAccountWeb.PluginRouter do
  @moduledoc false

  use HumoWeb.PluginRouterBehaviour

  def root() do
    quote location: :keep do
      pipeline :humo_account_require_authentication do
        plug HumoAccountWeb.RequireAuthenticationPlug
      end

      pipeline :humo_minimal_layout do
        plug :put_root_layout, {HumoWeb.layout_view(), "minimal-modal.html"}
      end

      scope "/", HumoAccountWeb do
        pipe_through :humo_minimal_layout

        get "/login", SessionController, :new
        post "/login", SessionController, :create
        delete "/logout", SessionController, :delete

        get "/signup", SignupController, :new
        post "/signup", SignupController, :create
        get "/verify-email", VerifyEmailController, :index
        get "/verify-email/:token", VerifyEmailController, :edit
        get "/reset-password", ResetPasswordController, :new
        post "/reset-password", ResetPasswordController, :create
        get "/reset-password/:token", ResetPasswordController, :edit
        patch "/reset-password/:token", ResetPasswordController, :update
      end

      scope "/", HumoAccountWeb do
        pipe_through :humo_account_require_authentication

        scope "/profile", Profile, as: :profile, assigns: %{page_pretitle: "Accounts"} do
          resources "/", UserController, only: [:show, :edit, :update], singleton: true
          resources "/email", UserEmailController, only: [:edit, :update], singleton: true
          resources "/password", UserPasswordController, only: [:edit, :update], singleton: true
        end
      end
    end
  end

  def dashboard() do
    quote location: :keep do
      scope "/", HumoAccountWeb.Dashboard, assigns: %{page_pretitle: "Accounts"} do
        resources "/users", UserController, except: [:new, :create]
      end
    end
  end
end
