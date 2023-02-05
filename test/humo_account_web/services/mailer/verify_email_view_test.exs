defmodule HumoAccountWeb.Mailer.VerifyEmailViewTest do
  use ExUnit.Case
  alias HumoAccountWeb.Mailer.VerifyEmailView

  test "password reset email" do
    user = %HumoAccount.UsersService.User{
      email: "user@mail.invalid",
      first_name: "Test",
      last_name: "User"
    }

    url = "http://verify_email_url"

    email = VerifyEmailView.render_email(%{user: user, verify_email_url: url})

    assert email.to == [{"Test User", "user@mail.invalid"}]
    assert email.subject == "Email verification"
    assert email.html_body =~ "verify email"
    assert email.html_body =~ url
    assert email.text_body =~ "verify email"
    assert email.text_body =~ url
  end
end
