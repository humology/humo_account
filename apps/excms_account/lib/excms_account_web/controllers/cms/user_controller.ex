defmodule ExcmsAccountWeb.Cms.UserController do
  use ExcmsAccountWeb, :controller

  alias ExcmsAccount.UsersService
  alias ExcmsAccount.UsersService.User
  alias ExcmsCore.GlobalAccess

  @page_size 50

  def rest_permissions(rest_action),
    do: [Permission.new(User, rest_action), Permission.new(GlobalAccess, "cms")]

  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    search = Map.get(params, "search")

    users = UsersService.page_users(page, @page_size, search)

    users_count = UsersService.count_users(search)
    page_max = div(users_count - 1, @page_size) + 1

    render(conn, "index.html", users: users, search: search, page: page, page_max: page_max)
  end

  def show(conn, %{"id" => id}) do
    user = UsersService.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = UsersService.get_user!(id)
    changeset = UsersService.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = UsersService.get_user!(id)

    case UsersService.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: routes().cms_user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = UsersService.get_user!(id)
    {:ok, _user} = UsersService.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: routes().cms_user_path(conn, :index))
  end
end
