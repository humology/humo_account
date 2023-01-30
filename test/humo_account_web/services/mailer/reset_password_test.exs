defmodule HumoAccountWeb.Mailer.ResetPasswordTest do
  use ExUnit.Case
  alias HumoAccountWeb.Mailer.ResetPassword

  test "password reset email" do
    user_email = "user@mail.invalid"
    url = "http://reset_password_url"

    email =
      %ResetPassword{to: user_email, reset_password_url: url}
      |> ResetPassword.render_email()

    assert email.to == [{"", user_email}]
    assert email.subject == "Password reset"
    assert email.html_body =~ "reset password"
    assert email.html_body =~ url
    assert email.text_body =~ "reset password"
    assert email.text_body =~ url
  end
end
