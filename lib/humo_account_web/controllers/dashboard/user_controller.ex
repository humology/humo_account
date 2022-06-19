defmodule HumoAccountWeb.Dashboard.UserController do
  use HumoAccountWeb, :controller

  alias HumoAccount.UsersService
  alias HumoAccount.UsersService.User
  alias HumoWeb.AuthorizationExtractor

  @page_size 50

  plug :assign_user when action in [:show, :edit, :update, :delete]

  use HumoWeb.AuthorizeControllerHelpers,
    resource_module: User,
    resource_assign_key: :user

  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    search = Map.get(params, "search")

    authorization = AuthorizationExtractor.extract(conn)

    users = UsersService.page_users(authorization, page, @page_size, search)

    users_count = UsersService.count_users(authorization, search)
    page_max = div(users_count - 1, @page_size) + 1

    render(
      conn,
      "index.html",
      users: users,
      search: search,
      page: page,
      page_max: page_max
    )
  end

  def show(conn, _params) do
    user = conn.assigns.user
    render(conn, "show.html", user: user)
  end

  def edit(conn, _params) do
    user = conn.assigns.user
    changeset = UsersService.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.user

    case UsersService.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: routes().dashboard_humo_account_user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    user = conn.assigns.user
    {:ok, _user} = UsersService.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: routes().dashboard_humo_account_user_path(conn, :index))
  end

  defp assign_user(conn, _opts) do
    assign(conn, :user, UsersService.get_user!(Map.fetch!(conn.params, "id")))
  end
end
