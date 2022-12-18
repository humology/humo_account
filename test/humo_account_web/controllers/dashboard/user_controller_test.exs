defmodule HumoAccountWeb.Dashboard.UserControllerTest do
  use HumoAccountWeb.ConnCase, async: true

  alias HumoAccount.UsersService
  alias HumoAccount.UsersService.User
  alias Humo.Authorizer.{AllAccess, Mock, NoAccess}
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
      for resource_can_actions <- [
            [],
            ["read"],
            ["update"],
            ["delete"],
            ["read", "update", "delete"]
          ] do
        fn ->
          conn = get(conn, routes().dashboard_humo_account_user_path(conn, :index))

          response = html_response(conn, 200)
          html = Floki.parse_fragment!(response)
          links = Floki.find(html, "a.dropdown-item") |> Floki.text()

          assert Floki.find(html, "h2.page-title") |> Floki.text() =~ "Users"
          assert response =~ @create_attrs.first_name
          assert links =~ "Show" == "read" in resource_can_actions
          assert links =~ "Edit" == "update" in resource_can_actions
          assert links =~ "Delete" == "delete" in resource_can_actions
        end
        |> Mock.with_mock(
          can_all: fn _, "read", User -> User end,
          can_actions: fn
            _, %User{} -> resource_can_actions
            _, {:list, User} -> ["read"]
          end
        )
      end
    end

    test "when list of record is empty, renders no user", %{conn: conn} do
      fn ->
        conn = get(conn, routes().dashboard_humo_account_user_path(conn, :index))

        response = html_response(conn, 200)
        html = Floki.parse_fragment!(response)
        links = Floki.find(html, "a.dropdown-item") |> Floki.text()

        assert Floki.find(html, "h2.page-title") |> Floki.text() =~ "Users"
        refute response =~ @create_attrs.first_name
        refute links =~ "Show"
        refute links =~ "Edit"
        refute links =~ "Delete"
      end
      |> Mock.with_mock(
        can_all: fn _, "read", User -> Humo.Repo.none(User) end,
        can_actions: &AllAccess.can_actions/2
      )
    end

    test "no access", %{conn: conn} do
      fn ->
        conn = get(conn, routes().dashboard_humo_account_user_path(conn, :index))
        assert response(conn, 403) =~ "Forbidden"
      end
      |> Mock.with_mock(can_actions: &NoAccess.can_actions/2)
    end
  end

  describe "edit user" do
    test "renders user edit form with allowed links", %{conn: conn, user: user} do
      for list_module_can_actions <- [["read"], []] do
        fn ->
          conn = get(conn, routes().dashboard_humo_account_user_path(conn, :edit, user))

          response = html_response(conn, 200)
          html = Floki.parse_fragment!(response)
          links = Floki.find(html, "a.btn.btn-link") |> Floki.text()

          assert Floki.find(html, "h2.page-title") |> Floki.text() =~ "Edit user"
          assert links =~ "Cancel" == "read" in list_module_can_actions
        end
        |> Mock.with_mock(
          can_actions: fn
            _, %User{} -> ["update"]
            _, {:list, User} -> list_module_can_actions
          end
        )
      end
    end

    test "no access", %{conn: conn, user: user} do
      fn ->
        conn = get(conn, routes().dashboard_humo_account_user_path(conn, :edit, user))
        assert response(conn, 403) =~ "Forbidden"
      end
      |> Mock.with_mock(can_actions: &NoAccess.can_actions/2)
    end
  end

  describe "update user" do
    test "redirects when data is valid", %{conn: conn, user: user} do
      fn ->
        conn =
          put(conn, routes().dashboard_humo_account_user_path(conn, :update, user),
            user: @update_attrs
          )

        assert redirected_to(conn) == routes().dashboard_humo_account_user_path(conn, :show, user)

        user = UsersService.get_user!(user.id)
        assert "updated@test.invalid" = user.email
      end
      |> Mock.with_mock(
        can_actions: fn
          _, %User{} -> ["update"]
        end
      )
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      fn ->
        conn =
          put(conn, routes().dashboard_humo_account_user_path(conn, :update, user),
            user: @invalid_attrs
          )

        html = Floki.parse_fragment!(html_response(conn, 200))
        assert Floki.find(html, "h2.page-title") |> Floki.text() =~ "Edit user"
      end
      |> Mock.with_mock(can_actions: &AllAccess.can_actions/2)
    end

    test "no access", %{conn: conn, user: user} do
      fn ->
        conn =
          put(conn, routes().dashboard_humo_account_user_path(conn, :update, user),
            user: @update_attrs
          )

        assert response(conn, 403) =~ "Forbidden"
      end
      |> Mock.with_mock(can_actions: &NoAccess.can_actions/2)
    end
  end

  describe "show" do
    test "renders show available actions", %{conn: conn, user: user} do
      for record_can_actions <- [["read", "update"], ["read"]],
          list_module_can_actions <- [["read"], []] do
        fn ->
          conn = get(conn, routes().dashboard_humo_account_user_path(conn, :show, user))

          html = Floki.parse_fragment!(html_response(conn, 200))
          links = Floki.find(html, "a.btn.btn-link") |> Floki.text()

          assert links =~ "Edit" == "update" in record_can_actions
          assert links =~ "Back" == "read" in list_module_can_actions
        end
        |> Mock.with_mock(
          can_actions: fn
            _, %User{} -> record_can_actions
            _, {:list, User} -> list_module_can_actions
          end
        )
      end
    end

    test "no access", %{conn: conn, user: user} do
      fn ->
        conn = get(conn, routes().dashboard_humo_account_user_path(conn, :show, user))
        assert response(conn, 403) =~ "Forbidden"
      end
      |> Mock.with_mock(can_actions: &NoAccess.can_actions/2)
    end
  end

  describe "delete user" do
    test "deletes chosen user", %{conn: conn, user: user} do
      fn ->
        conn = delete(conn, routes().dashboard_humo_account_user_path(conn, :delete, user))
        assert redirected_to(conn) == routes().dashboard_humo_account_user_path(conn, :index)

        assert_error_sent(404, fn ->
          get(conn, routes().dashboard_humo_account_user_path(conn, :show, user))
        end)
      end
      |> Mock.with_mock(can_actions: fn _, %User{} -> ["delete"] end)
    end

    test "no access", %{conn: conn, user: user} do
      fn ->
        conn = delete(conn, routes().dashboard_humo_account_user_path(conn, :delete, user))
        assert response(conn, 403) =~ "Forbidden"
      end
      |> Mock.with_mock(can_actions: &NoAccess.can_actions/2)
    end
  end
end
