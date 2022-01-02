defmodule ExcmsAccountWeb.SessionControllerTest do
  use ExcmsAccount.ConnCase, async: false

  setup %{conn: conn} do
    user = insert(:user)

    conn = put_req_header(conn, "accept-language", "en")

    %{conn: conn, user: user}
  end

  test "success", %{conn: conn, user: user} do
    conn = get(conn, routes().session_path(conn, :new))

    assert html_response(conn, 200) =~
             "<form action=\"#{routes().session_path(conn, :create)}\" method=\"post\">"

    email = user.email

    params = %{
      email: email,
      password: "password"
    }

    conn = post(conn, routes().session_path(conn, :create), params)

    user_id = user.id
    assert %{"user_id" => ^user_id} = get_session(conn)
    assert redirected_to(conn) == routes().dashboard_user_path(conn, :index)

    conn = get(conn, routes().dashboard_user_path(conn, :index))
    assert html_response(conn, 200)

    conn = delete(conn, routes().session_path(conn, :delete))
    assert %{} = get_session(conn)
  end

  test "not verified email", %{conn: conn} do
    user_not_verified = insert(:user, email_verified_at: nil)
    email = user_not_verified.email

    params = %{email: email, password: "password"}
    conn = post(conn, routes().session_path(conn, :create), params)
    assert redirected_to(conn) == routes().verify_email_path(conn, :index)

    assert_receive %Bamboo.Email{to: ^email}
  end

  test "wrong password", %{conn: conn, user: user} do
    email = user.email

    params = %{
      email: email,
      password: "wrong_password"
    }

    conn = post(conn, routes().session_path(conn, :create), params)
    assert html_response(conn, 200) =~ "Bad email/password combination"
  end
end