defmodule ExcmsAccountWeb.Profile.UserEmailControllerTest do
  use ExcmsServer.ConnCase, async: false
  alias ExcmsAccount.UsersService

  setup %{conn: conn} do
    user = insert(:user)

    params = %{email: user.email, password: "password"}

    conn = conn
    |> put_req_header("accept-language", "en")
    |> post(routes().session_path(conn, :create), params)

    %{conn: conn, user: user}
  end

  test "edit", %{conn: conn, user: user} do
    conn = get(conn, routes().profile_user_email_path(conn, :edit))
    assert html_response(conn, 200) =~ "<form action=\"#{
             routes().profile_user_email_path(conn, :update)}\" method=\"post\">"

    email = "some@other.email"
    params = %{"user" => %{email: email, current_password: "password"}}
    conn = patch(conn, routes().profile_user_email_path(conn, :update), params)

    assert UsersService.get_user_by_email(email)
    refute UsersService.get_user_by_email(user.email)

    assert redirected_to(conn) == routes().profile_user_path(conn, :show)
  end

  test "edit wrong password", %{conn: conn, user: user} do
    conn = get(conn, routes().profile_user_email_path(conn, :edit))
    assert html_response(conn, 200) =~ "<form action=\"#{
             routes().profile_user_email_path(conn, :update)}\" method=\"post\">"

    params = %{"user" =>
      %{
        email: "some@other.email",
        current_password: "wrongpassword"
      }
    }
    conn = patch(conn, routes().profile_user_email_path(conn, :update), params)

    assert UsersService.get_user_by_email(user.email)
    refute UsersService.get_user_by_email("some@other.email")

    assert html_response(conn, 200) =~ "phx-feedback-for=\"user_current_password\""
  end
end
