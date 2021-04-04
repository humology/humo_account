defmodule ExcmsAccountWeb.Cms.UserControllerTest do
  use ExcmsServer.ConnCase

  alias ExcmsAccount.UsersService

  @create_attrs %{email: "SOME@test.invalid", first_name: "some first_name", last_name: "some last_name", password: "some password"}
  @update_attrs %{email: "UPDATED@test.invalid", first_name: "some updated first_name", last_name: "some updated last_name", password: "some updated password"}
  @invalid_attrs %{email: nil, first_name: nil, last_name: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = UsersService.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    user = insert(:user)

    conn = conn
    |> Plug.Test.init_test_session(user_id: user.id)

    %{conn: conn}
  end

  describe "index" do
    test "lists all user", %{conn: conn} do
      conn = get(conn, routes().cms_user_path(conn, :index))
      assert html_response(conn, 200) =~ "<h3>Users</h3>"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, routes().cms_user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, routes().cms_user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == routes().cms_user_path(conn, :show, user)

      conn = get(conn, routes().cms_user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "updated@test.invalid"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, routes().cms_user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, routes().cms_user_path(conn, :delete, user))
      assert redirected_to(conn) == routes().cms_user_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, routes().cms_user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
