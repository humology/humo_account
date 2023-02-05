defmodule HumoAccountWeb.Profile.UserControllerTest do
  use HumoAccountWeb.ConnCase, async: true
  alias HumoAccount.Accounts

  setup %{conn: conn} do
    user = insert(:user)

    params = %{email: user.email, password: "password"}

    conn =
      conn
      |> put_req_header("accept-language", "en")
      |> post(routes().humo_account_session_path(conn, :create), params)

    %{conn: conn, user: user}
  end

  test "show", %{conn: conn} do
    conn = get(conn, routes().humo_account_profile_user_path(conn, :show))
    assert html_response(conn, 200) =~ "<strong>Profile</strong>"
  end

  test "edit", %{conn: conn, user: user} do
    conn = get(conn, routes().humo_account_profile_user_path(conn, :edit))

    assert html_response(conn, 200) =~
             "<form action=\"#{routes().humo_account_profile_user_path(conn, :update)}\" method=\"post\">"

    params = %{
      "user" => %{
        first_name: "Some other first_name",
        last_name: "Some other last_name",
        email: "some_other@email"
      }
    }

    conn = patch(conn, routes().humo_account_profile_user_path(conn, :update), params)

    email = user.email

    assert %{
             first_name: "Some other first_name",
             last_name: "Some other last_name",
             email: ^email
           } = Accounts.get_user_by_email(email)

    assert redirected_to(conn) == routes().humo_account_profile_user_path(conn, :show)
  end
end
