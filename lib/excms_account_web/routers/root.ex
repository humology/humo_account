defmodule ExcmsAccountWeb.Routers.Root do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote location: :keep do
      pipeline :excms_account_require_authentication do
        plug ExcmsAccountWeb.RequireAuthenticationPlug
      end

      scope "/", ExcmsAccountWeb do
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

      scope "/", ExcmsAccountWeb do
        pipe_through :excms_account_require_authentication

        scope "/profile", Profile, as: :profile do
          resources "/", UserController, only: [:show, :edit, :update], singleton: true
          resources "/email", UserEmailController, only: [:edit, :update], singleton: true
          resources "/password", UserPasswordController, only: [:edit, :update], singleton: true
        end
      end
    end
  end
end