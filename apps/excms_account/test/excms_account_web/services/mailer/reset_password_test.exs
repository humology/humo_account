defmodule ExcmsAccountWeb.Mailer.ResetPasswordTest do
  use ExUnit.Case
  alias ExcmsAccountWeb.Mailer.ResetPassword

  test "password reset email" do
    email = "user@mail.invalid"
    url = "http://reset_password_url"

    mail =
      %ResetPassword{to: email, reset_password_url: url}
      |> ResetPassword.render_email()

    assert mail.to == email
    assert mail.subject == "Password reset"
    assert mail.html_body =~ "reset password"
    assert mail.html_body =~ url
    assert mail.text_body =~ "reset password"
    assert mail.text_body =~ url
  end
end
