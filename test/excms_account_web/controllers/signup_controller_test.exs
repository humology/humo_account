defmodule ExcmsAccountWeb.SignupControllerTest do
  use ExcmsAccountWeb.ConnCase, async: false
  alias ExcmsAccount.UsersService

  setup %{conn: conn} do
    user = insert(:user)

    conn = put_req_header(conn, "accept-language", "en")

    %{conn: conn, user: user}
  end

  test "show form", %{conn: conn} do
    conn = get(conn, routes().signup_path(conn, :new))

    assert html_response(conn, 200) =~
             "<form action=\"#{routes().signup_path(conn, :create)}\" method=\"post\">"
  end

  test "success", %{conn: conn} do
    email = "jack@example.invalid"

    params = %{
      "user" => %{
        first_name: "Jack",
        last_name: "Smith",
        email: email,
        password: "password"
      }
    }

    conn = post(conn, routes().signup_path(conn, :create), params)
    assert redirected_to(conn) == routes().verify_email_path(conn, :index)

    assert %{email_verified_at: nil} = UsersService.get_user_by_email(email)
  end

  test "duplicate email", %{conn: conn, user: user} do
    email = user.email

    params = %{
      "user" => %{
        first_name: "Jack",
        last_name: "Smith",
        email: email,
        password: "password"
      }
    }

    conn = post(conn, routes().signup_path(conn, :create), params)
    assert html_response(conn, 200) =~ "user_email\">has already been taken"
  end
end
