defmodule HumoAccountWeb.Profile.UserEmailController do
  use HumoAccountWeb, :controller
  alias HumoAccount.UsersService

  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = UsersService.change_user(user)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => params}) do
    user = conn.assigns.current_user

    case UsersService.update_user_email(user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: routes().humo_account_profile_user_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end
end
