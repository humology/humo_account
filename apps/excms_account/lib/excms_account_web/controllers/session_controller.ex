defmodule ExcmsAccountWeb.SessionController do
  use ExcmsAccountWeb, :controller

  alias ExcmsAccountWeb.AuthService

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case AuthService.authenticate_by_email_password(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: routes().cms_user_path(conn, :index))

      {:error, :email_not_verified, email} ->
        AuthService.send_verify_email(email)

        conn
        |> redirect(to: routes().verify_email_path(conn, :index))

      {:error, :unauthorized} ->
        conn
        |> put_flash(:error, "Bad email/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
