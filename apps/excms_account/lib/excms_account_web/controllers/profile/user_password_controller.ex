defmodule ExcmsAccountWeb.Profile.UserPasswordController do
  use ExcmsAccountWeb, :controller
  alias ExcmsAccount.UsersService

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = UsersService.change_user(user)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => params}) do
    user = conn.assigns.current_user

    case UsersService.update_user_password(user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> configure_session(renew: true)
        |> redirect(to: routes().profile_user_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end
end
