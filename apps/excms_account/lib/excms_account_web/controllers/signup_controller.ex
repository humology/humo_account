defmodule ExcmsAccountWeb.SignupController do
  use ExcmsAccountWeb, :controller

  alias ExcmsAccount.UsersService
  alias ExcmsAccount.UsersService.User
  alias ExcmsAccountWeb.AuthService

  def new(conn, _) do
    changeset = UsersService.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case UsersService.create_user(user_params) do
      {:ok, %{email: email}} ->
        AuthService.send_verify_email(email)

        conn
        |> redirect(to: routes().verify_email_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
