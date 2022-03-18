defmodule ExcmsAccountWeb.Dashboard.UserControllerTest do
  use ExcmsAccountWeb.ConnCase

  alias ExcmsAccount.UsersService
  alias ExcmsAccount.UsersService.User
  alias ExcmsCore.Authorizer.{Mock, AllAccess, NoAccess}
  import Ecto.Query, warn: false

  @create_attrs %{
    email: "SOME@test.invalid",
    first_name: "some first_name",
    last_name: "some last_name",
    password: "some password"
  }
  @update_attrs %{
    email: "UPDATED@test.invalid",
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    password: "some updated password"
  }
  @invalid_attrs %{email: nil, first_name: nil, last_name: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = UsersService.create_user(@create_attrs)
    user
  end

  setup do
    %{user: fixture(:user)}
  end

  describe "index" do
    test "render allowed links", %{conn: conn} do
      for resource_can_actions <- [[], ["read"], ["update"], ["delete"], ["read", "update", "delete"]] do
        fn ->
          conn = get(conn, routes().dashboard_user_path(conn, :index))
          assert html_response(conn, 200) =~ "<h3>Users</h3>"
          assert html_response(conn, 200) =~ @create_attrs.first_name
          assert (html_response(conn, 200) =~ "Show") == ("read" in resource_can_actions)
          assert (html_response(conn, 200) =~ "Edit") == ("update" in resource_can_actions)
          assert (html_response(conn, 200) =~ "Delete") == ("delete" in resource_can_actions)
        end
        |> Mock.with_mock(
          can_all: fn _, "read", User -> User end,
          can_actions: fn
            _, %User{} -> resource_can_actions
            _, User -> ["read"]
          end
        )
      end
    end

    test "when list of record is empty, renders no user", %{conn: conn} do
      fn ->
        conn = get(conn, routes().dashboard_user_path(conn, :index))
        assert html_response(conn, 200) =~ "<h3>Users</h3>"
        refute html_response(conn, 200) =~ @create_attrs.first_name
        refute html_response(conn, 200) =~ "Show"
        refute html_response(conn, 200) =~ "Edit"
        refute html_response(conn, 200) =~ "Delete"
      end
      |> Mock.with_mock(
        can_all: fn _, "read", User -> ExcmsCore.Repo.none(User) end,
        can_actions: &AllAccess.can_actions/2
      )
    end

    test "no access", %{conn: conn} do
      fn ->
        conn = get(conn, routes().dashboard_user_path(conn, :index))
        assert response(conn, 403) =~ "Forbidden"
      end
      |> Mock.with_mock(can_actions: &NoAccess.can_actions/2)
    end
  end

  describe "edit" do
    test "renders user edit form with allowed links", %{conn: conn, user: user} do
      for module_can_actions <- [["read"], []] do
        fn ->
          conn = get(conn, routes().dashboard_user_path(conn, :edit, user))
          assert html_response(conn, 200) =~ "Edit User"
          assert (html_response(conn, 200) =~ "Back") == ("read" in module_can_actions)
        end
        |> Mock.with_mock(can_actions: fn
          _, %User{} -> ["update"]
          _, User -> module_can_actions
        end)
      end
    end

    test "no access to index", %{conn: conn, user: user} do
      fn ->
        conn = get(conn, routes().dashboard_user_path(conn, :edit, user))
        assert html_response(conn, 200) =~ "Edit User"
        refute html_response(conn, 200) =~ "Back"
      end
      |> Mock.with_mock(can_actions: fn
        _, %User{} -> ["update"]
        _, User -> []
      end)
    end

    test "no access", %{conn: conn, user: user} do
      fn ->
        conn = get(conn, routes().dashboard_user_path(conn, :edit, user))
        assert response(conn, 403) =~ "Forbidden"
      end
      |> Mock.with_mock(can_actions: &NoAccess.can_actions/2)
    end
  end

  describe "update user" do
    test "redirects when data is valid", %{conn: conn, user: user} do
      fn ->
        conn = put(conn, routes().dashboard_user_path(conn, :update, user), user: @update_attrs)
        assert redirected_to(conn) == routes().dashboard_user_path(conn, :show, user)

        conn = get(conn, routes().dashboard_user_path(conn, :show, user))
        assert html_response(conn, 200) =~ "updated@test.invalid"
      end
      |> Mock.with_mock(can_actions: &AllAccess.can_actions/2)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      fn ->
        conn = put(conn, routes().dashboard_user_path(conn, :update, user), user: @invalid_attrs)
        assert html_response(conn, 200) =~ "Edit User"
      end
      |> Mock.with_mock(can_actions: &AllAccess.can_actions/2)
    end
  end

  describe "show" do
    test "renders show available actions", %{conn: conn, user: user} do
      for record_can_actions <- [["read", "update"], ["read"]],
          module_can_actions <- [["read"], []] do
        fn ->
          conn = get(conn, routes().dashboard_user_path(conn, :show, user))
          assert (html_response(conn, 200) =~ "Edit") == ("update" in record_can_actions)
          assert (html_response(conn, 200) =~ "Back") == ("read" in module_can_actions)
        end
        |> Mock.with_mock(can_actions: fn
          _, %User{} -> record_can_actions
          _, User -> module_can_actions
        end)
      end
    end

    test "no access", %{conn: conn, user: user} do
      fn ->
        conn = get(conn, routes().dashboard_user_path(conn, :show, user))
        assert response(conn, 403) =~ "Forbidden"
      end
      |> Mock.with_mock(can_actions: &NoAccess.can_actions/2)
    end
  end

  describe "delete user" do
    test "deletes chosen user", %{conn: conn, user: user} do
      fn ->
        conn = delete(conn, routes().dashboard_user_path(conn, :delete, user))
        assert redirected_to(conn) == routes().dashboard_user_path(conn, :index)

        assert_error_sent 404, fn ->
          get(conn, routes().dashboard_user_path(conn, :show, user))
        end
      end
      |> Mock.with_mock(can_actions: fn _, %User{} -> ["delete"] end)
    end

    test "no access", %{conn: conn, user: user} do
      fn ->
        conn = delete(conn, routes().dashboard_user_path(conn, :delete, user))
        assert response(conn, 403) =~ "Forbidden"
      end
      |> Mock.with_mock(can_actions: &NoAccess.can_actions/2)
    end
  end
end
