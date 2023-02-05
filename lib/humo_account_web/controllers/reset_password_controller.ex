defmodule HumoAccountWeb.ResetPasswordController do
  use HumoAccountWeb, :controller

  alias HumoAccount.UsersService
  alias HumoAccountWeb.AuthService

  plug(:scrub_params, "token" when action in [:update])

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email}) do
    case UsersService.get_user_by_email(email) do
      %UsersService.User{} = user ->
        AuthService.send_reset_password_email(user)

      _ ->
        :ok
    end

    render(conn, "reset_password_sent.html")
  end

  def edit(conn, %{"token" => token}) do
    case AuthService.change_user_reset_password(token) do
      {:error, :expired_or_invalid_token} ->
        render(conn, "edit.html", token: token, changeset: nil)

      %Ecto.Changeset{} = changeset ->
        render(conn, "edit.html", token: token, changeset: changeset)
    end
  end

  def update(conn, %{"token" => token, "user" => user_params}) do
    case AuthService.update_user_reset_password(token, user_params) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: routes().dashboard_humo_account_user_path(conn, :index))

      {:error, :expired_or_invalid_token} ->
        render(conn, "edit.html", token: token, changeset: nil)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", token: token, changeset: changeset)
    end
  end
end
