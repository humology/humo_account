defmodule ExcmsAccountWeb.Profile.UserControllerTest do
  use ExcmsServer.ConnCase, async: false
  alias ExcmsAccount.UsersService

  setup %{conn: conn} do
    user = insert(:user)

    params = %{email: user.email, password: "password"}

    conn =
      conn
      |> put_req_header("accept-language", "en")
      |> post(routes().session_path(conn, :create), params)

    %{conn: conn, user: user}
  end

  test "show", %{conn: conn} do
    conn = get(conn, routes().profile_user_path(conn, :show))
    assert html_response(conn, 200) =~ "<h3>My Profile</h3>"
  end

  test "edit", %{conn: conn, user: user} do
    conn = get(conn, routes().profile_user_path(conn, :edit))

    assert html_response(conn, 200) =~
             "<form action=\"#{routes().profile_user_path(conn, :update)}\" method=\"post\">"

    params = %{
      "user" => %{
        first_name: "Some other first_name",
        last_name: "Some other last_name",
        email: "some_other@email"
      }
    }

    conn = patch(conn, routes().profile_user_path(conn, :update), params)

    email = user.email

    assert %{
             first_name: "Some other first_name",
             last_name: "Some other last_name",
             email: ^email
           } = UsersService.get_user_by_email(email)

    assert redirected_to(conn) == routes().profile_user_path(conn, :show)
  end
end
