defmodule ExcmsAccountWeb.ResetPasswordController do
  use ExcmsAccountWeb, :controller

  alias ExcmsAccountWeb.AuthService

  plug :scrub_params, "token" when action in [:update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email}) do
    AuthService.send_reset_password_email(email)
    render(conn, "reset_password_sent.html")
  end

  def edit(conn, %{"token" => token}) do
    case AuthService.change_user_reset_password(token) do
      {:error, :failed} ->
        render(conn, "edit.html", token: token, changeset: nil)

      %Ecto.Changeset{} = changeset ->
        render(conn, "edit.html", token: token, changeset: changeset)
    end
  end

  def update(conn, %{"token" => token, "user" => user_params}) do
    case AuthService.update_user_reset_password(token, user_params) do
      {:ok, user} ->
        AuthService.set_email_verified(token)

        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: routes().dashboard_user_path(conn, :index))

      {:error, :failed} ->
        render(conn, "edit.html", token: token, changeset: nil)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", token: token, changeset: changeset)
    end
  end
end
