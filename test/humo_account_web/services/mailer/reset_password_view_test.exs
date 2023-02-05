defmodule HumoAccountWeb.Mailer.ResetPasswordViewTest do
  use ExUnit.Case
  alias HumoAccountWeb.Mailer.ResetPasswordView

  test "password reset email" do
    user = %HumoAccount.Accounts.User{
      email: "user@mail.invalid",
      first_name: "Test",
      last_name: "User"
    }

    url = "http://reset_password_url"

    email = ResetPasswordView.render_email(%{user: user, reset_password_url: url})

    assert email.to == [{"Test User", "user@mail.invalid"}]
    assert email.subject == "Password reset"
    assert email.html_body =~ "reset password"
    assert email.html_body =~ url
    assert email.text_body =~ "reset password"
    assert email.text_body =~ url
  end
end
