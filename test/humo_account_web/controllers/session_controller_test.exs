defmodule HumoAccountWeb.SessionControllerTest do
  use HumoAccountWeb.ConnCase, async: true
  alias Humo.Authorizer.AllAccess
  alias Humo.Authorizer.Mock

  describe "login" do
    test "login form", %{conn: conn} do
      fn ->
        conn = get(conn, routes().humo_account_session_path(conn, :new))

        assert html_response(conn, 200) =~
                "<form action=\"#{routes().humo_account_session_path(conn, :create)}\" method=\"post\">"
      end
      |> Mock.with_mock(can_actions: &AllAccess.can_actions/2)
    end

    test "login with correct email and password", %{conn: conn} do
      fn ->
        user = insert(:user)
        params = %{email: user.email, password: "password"}
        conn = post(conn, routes().humo_account_session_path(conn, :create), params)

        user_id = user.id
        assert %{"user_id" => ^user_id} = get_session(conn)
        assert redirected_to(conn) == routes().dashboard_humo_account_user_path(conn, :index)
      end
      |> Mock.with_mock(can_actions: &AllAccess.can_actions/2)
    end

    test "wrong password", %{conn: conn} do
      fn ->
        user = insert(:user)
        params = %{email: user.email, password: "wrong_password"}

        conn = post(conn, routes().humo_account_session_path(conn, :create), params)
        assert html_response(conn, 200) =~ "Bad email/password combination"
      end
      |> Mock.with_mock(can_actions: &AllAccess.can_actions/2)
    end

    test "not verified email", %{conn: conn} do
      fn ->
        user_not_verified = insert(:user, email_verified_at: nil)
        email = user_not_verified.email

        params = %{email: email, password: "password"}
        conn = post(conn, routes().humo_account_session_path(conn, :create), params)
        assert redirected_to(conn) == routes().humo_account_verify_email_path(conn, :index)

        assert_receive %Bamboo.Email{to: ^email}
      end
      |> Mock.with_mock(can_actions: &AllAccess.can_actions/2)
    end
  end

  describe "logout" do
    setup %{conn: conn} do
      user = insert(:user)

      params = %{email: user.email, password: "password"}
      conn = post(conn, routes().humo_account_session_path(conn, :create), params)

      %{conn: conn}
    end

    test "with logout session is cleaned", %{conn: conn} do
      fn ->
        conn = delete(conn, routes().humo_account_session_path(conn, :delete))
        assert redirected_to(conn)
        assert %{} == get_session(conn)
      end
      |> Mock.with_mock(can_actions: &AllAccess.can_actions/2)
    end
  end
end
