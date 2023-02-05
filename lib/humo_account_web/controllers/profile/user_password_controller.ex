defmodule HumoAccountWeb.Profile.UserPasswordController do
  use HumoAccountWeb, :controller
  alias HumoAccount.Accounts

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", changeset: changeset, page_title: "Edit password")
  end

  def update(conn, %{"user" => params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> configure_session(renew: true)
        |> redirect(to: routes().humo_account_profile_user_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset, page_title: "Edit password")
    end
  end
end
