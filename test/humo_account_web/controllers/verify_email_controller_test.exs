defmodule HumoAccountWeb.VerifyEmailControllerTest do
  use HumoAccountWeb.ConnCase, async: true
  alias HumoAccount.Accounts
  import Swoosh.TestAssertions

  setup %{conn: conn} do
    user = insert(:user)

    conn = put_req_header(conn, "accept-language", "en")

    %{conn: conn, user: user}
  end

  test "success", %{conn: conn} do
    user_email = "jack@example.invalid"

    params = %{
      "user" => %{
        first_name: "Jack",
        last_name: "Smith",
        email: user_email,
        password: "password"
      }
    }

    conn = post(conn, routes().humo_account_signup_path(conn, :create), params)
    assert redirected_to(conn) == routes().humo_account_verify_email_path(conn, :index)

    assert %{email_verified_at: nil} = Accounts.get_user_by_email(user_email)

    %{assigns: %{verify_email_url: verify_email_url}} =
      assert_email_sent(fn email ->
        assert email.subject == "Email verification"
        assert email.to == [{"Jack Smith", user_email}]

        email
      end)

    conn = get(conn, verify_email_url)
    assert html_response(conn, 200) =~ "Email verification success"

    assert %{email_verified_at: %DateTime{}} = Accounts.get_user_by_email(user_email)
  end
end
