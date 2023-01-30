defmodule HumoAccountWeb.ResetPasswordControllerTest do
  use HumoAccountWeb.ConnCase, async: true
  alias HumoAccount.UsersService
  import Swoosh.TestAssertions

  setup %{conn: conn} do
    user = insert(:user)

    conn = put_req_header(conn, "accept-language", "en")

    %{conn: conn, user: user}
  end

  test "show form", %{conn: conn} do
    conn = get(conn, routes().humo_account_reset_password_path(conn, :new))

    assert html_response(conn, 200) =~
             "<form action=\"#{routes().humo_account_reset_password_path(conn, :create)}\" method=\"post\">"
  end

  test "wrong token", %{conn: conn} do
    conn = get(conn, routes().humo_account_reset_password_path(conn, :edit, "wrong_token"))

    assert html_response(conn, 200) =~
             "Link expired, please request another"
  end

  test "success", %{conn: conn, user: user} do
    %{password_hash: password_hash} = UsersService.get_user_by_email(user.email)
    assert Bcrypt.verify_pass("password", password_hash)

    conn =
      post(conn, routes().humo_account_reset_password_path(conn, :create), %{email: user.email})

    assert html_response(conn, 200) =~ "reset password was sent"

    %{assigns: %{reset_password_url: reset_password_url}} =
      assert_email_sent(fn email ->
        assert email.subject == "Password reset"
        assert email.to == [{"", user.email}]

        email
      end)

    conn = get(conn, reset_password_url)

    assert response = html_response(conn, 200)

    {:ok, html} = Floki.parse_document(response)

    [{"form", [{"action", reset_password_update}, {"method", "post"}], _}] =
      Floki.find(html, "form")

    conn = patch(conn, reset_password_update, %{user: %{password: "new_password"}})

    user_id = user.id
    assert %{"user_id" => ^user_id} = get_session(conn)

    assert redirected_to(conn) == routes().dashboard_humo_account_user_path(conn, :index)

    %{password_hash: password_hash} = UsersService.get_user_by_email(user.email)
    assert Bcrypt.verify_pass("new_password", password_hash)
  end

  test "not registered", %{conn: conn} do
    email = "random@example.invalid"
    conn = post(conn, routes().humo_account_reset_password_path(conn, :create), %{email: email})

    assert html_response(conn, 200) =~ "reset password was sent"
    refute_email_sent()
  end
end
