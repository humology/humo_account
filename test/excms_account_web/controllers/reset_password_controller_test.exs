defmodule ExcmsAccountWeb.ResetPasswordControllerTest do
  use ExcmsAccountWeb.ConnCase, async: true
  alias ExcmsAccount.UsersService

  setup %{conn: conn} do
    user = insert(:user)

    conn = put_req_header(conn, "accept-language", "en")

    %{conn: conn, user: user}
  end

  test "show form", %{conn: conn} do
    conn = get(conn, routes().reset_password_path(conn, :new))

    assert html_response(conn, 200) =~
             "<form action=\"#{routes().reset_password_path(conn, :create)}\" method=\"post\">"
  end

  test "wrong token", %{conn: conn} do
    conn = get(conn, routes().reset_password_path(conn, :edit, "wrong_token"))

    assert html_response(conn, 200) =~
             "Link expired, please request another password reset"
  end

  test "success", %{conn: conn, user: user} do
    email = user.email

    %{password_hash: password_hash} = UsersService.get_user_by_email(email)
    assert Bcrypt.verify_pass("password", password_hash)

    conn = post(conn, routes().reset_password_path(conn, :create), %{email: email})

    assert html_response(conn, 200) =~ "reset password was sent"

    assert_receive %Bamboo.Email{to: ^email, assigns: %{reset_password_url: reset_password_url}}

    reset_password_prefix = routes().reset_password_path(conn, :edit, "")
    [_, token] = String.split(reset_password_url, reset_password_prefix)

    conn = get(conn, reset_password_url)
    reset_password_update = routes().reset_password_path(conn, :update, token)

    assert html_response(conn, 200) =~
             "<form action=\"#{reset_password_update}\" method=\"post\">"

    conn = patch(conn, reset_password_update, %{user: %{password: "new_password"}})

    user_id = user.id
    assert %{"user_id" => ^user_id} = get_session(conn)

    assert redirected_to(conn) == routes().dashboard_user_path(conn, :index)

    %{password_hash: password_hash} = UsersService.get_user_by_email(email)
    assert Bcrypt.verify_pass("new_password", password_hash)
  end

  test "not registered", %{conn: conn} do
    email = "random@example.invalid"

    conn = post(conn, routes().reset_password_path(conn, :create), %{email: email})

    assert html_response(conn, 200) =~ "reset password was sent"

    refute_receive %Bamboo.Email{}, 100
  end
end
