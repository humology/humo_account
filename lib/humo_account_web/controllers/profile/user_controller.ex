defmodule HumoAccountWeb.Profile.UserController do
  use HumoAccountWeb, :controller
  alias HumoAccount.Accounts

  use HumoWeb.AuthorizeControllerHelpers,
    resource_module: User,
    resource_assign_key: :current_user

  def can?(conn, _phoenix_action) do
    !is_nil(conn.assigns[:current_user])
  end

  def show(conn, _params) do
    render(conn, "show.html", page_title: "Profile")
  end

  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", changeset: changeset, page_title: "Edit profile")
  end

  def update(conn, %{"user" => params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_profile(user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: routes().humo_account_profile_user_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset, page_title: "Edit profile")
    end
  end
end
