defmodule HumoAccountWeb.SessionController do
  use HumoAccountWeb, :controller

  alias HumoAccountWeb.AuthService

  use HumoWeb.AuthorizeControllerHelpers,
    resource_module: User,
    resource_assign_key: :current_user

  def can?(conn, phoenix_action) when phoenix_action in [:new, :create] do
    is_nil(conn.assigns[:current_user])
  end

  def can?(conn, :delete) do
    !is_nil(conn.assigns[:current_user])
  end

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case AuthService.authenticate_by_email_password(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: routes().dashboard_humo_account_user_path(conn, :index))

      {:error, :email_not_verified, user} ->
        AuthService.send_verify_email(user)

        conn
        |> redirect(to: routes().humo_account_verify_email_path(conn, :index))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Bad email/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
