defmodule HumoAccountWeb.Profile.UserPasswordControllerTest do
  use HumoAccountWeb.ConnCase, async: true
  alias HumoAccount.UsersService

  setup %{conn: conn} do
    user = insert(:user)

    params = %{email: user.email, password: "password"}

    authenticated_conn =
      post(conn, routes().session_path(conn, :create), params)

    %{conn: authenticated_conn, user: user}
  end

  test "edit", %{conn: conn, user: user} do
    conn = get(conn, routes().profile_user_password_path(conn, :edit))

    assert html_response(conn, 200) =~
             "<form action=\"#{routes().profile_user_password_path(conn, :update)}\" method=\"post\">"

    password = "newpassword"
    params = %{"user" => %{password: password, current_password: "password"}}
    conn = patch(conn, routes().profile_user_password_path(conn, :update), params)

    %{password_hash: password_hash} = UsersService.get_user_by_email(user.email)
    assert Bcrypt.verify_pass("newpassword", password_hash)

    assert redirected_to(conn) == routes().profile_user_path(conn, :show)
  end

  test "edit wrong password", %{conn: conn, user: user} do
    conn = get(conn, routes().profile_user_email_path(conn, :edit))

    assert html_response(conn, 200) =~
             "<form action=\"#{routes().profile_user_email_path(conn, :update)}\" method=\"post\">"

    password = "newpassword"
    params = %{"user" => %{password: password, current_password: "wrongpassword"}}
    conn = patch(conn, routes().profile_user_password_path(conn, :update), params)

    %{password_hash: password_hash} = UsersService.get_user_by_email(user.email)
    assert Bcrypt.verify_pass("password", password_hash)
    assert html_response(conn, 200) =~ "phx-feedback-for=\"user_current_password\""
  end
end
