defmodule ExcmsAccountWeb.VerifyEmailControllerTest do
  use ExcmsServer.ConnCase, async: false
  alias ExcmsMailWeb.Mailer.VerifyEmail
  alias ExcmsMailWeb.MailerDummy
  alias ExcmsAccount.UsersService

  setup %{conn: conn} do
    user = insert(:user)

    conn = conn
    |> put_req_header("accept-language", "en")

    MailerDummy.test_init()

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
    conn = post(conn, routes().signup_path(conn, :create), params)
    assert redirected_to(conn) == routes().verify_email_path(conn, :index)

    assert %{email_verified_at: nil} = UsersService.get_user_by_email(email)

    [{
      ^email,
      %VerifyEmail{to: ^email, email_verified_url: email_verified_url}
    }] = MailerDummy.test_get_messages_by_email(email)

    conn = get(conn, email_verified_url)
    assert html_response(conn, 200) =~ "Email was verified, now you can login"

    assert %{email_verified_at: %DateTime{}} = UsersService.get_user_by_email(email)
  end
end
