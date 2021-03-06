defmodule HumoAccountWeb.VerifyEmailControllerTest do
  use HumoAccountWeb.ConnCase, async: true
  alias HumoAccount.UsersService

  setup %{conn: conn} do
    user = insert(:user)

    conn = put_req_header(conn, "accept-language", "en")

    %{conn: conn, user: user}
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

    conn = post(conn, routes().humo_account_signup_path(conn, :create), params)
    assert redirected_to(conn) == routes().humo_account_verify_email_path(conn, :index)

    assert %{email_verified_at: nil} = UsersService.get_user_by_email(email)

    assert_receive %Bamboo.Email{to: ^email, assigns: %{email_verified_url: email_verified_url}}

    conn = get(conn, email_verified_url)
    assert html_response(conn, 200) =~ "Email was verified, now you can login"

    assert %{email_verified_at: %DateTime{}} = UsersService.get_user_by_email(email)
  end
end
