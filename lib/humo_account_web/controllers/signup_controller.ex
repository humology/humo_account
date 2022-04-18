defmodule HumoAccountWeb.SignupController do
  use HumoAccountWeb, :controller

  alias HumoAccount.UsersService
  alias HumoAccount.UsersService.User
  alias HumoAccountWeb.AuthService

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
