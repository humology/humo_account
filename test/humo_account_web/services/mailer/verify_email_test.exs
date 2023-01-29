defmodule HumoAccountWeb.Mailer.VerifyEmailTest do
  use ExUnit.Case
  alias HumoAccountWeb.Mailer.VerifyEmail

  test "password reset email" do
    email = "user@mail.invalid"
    url = "http://verify_email_url"

    mail =
      %VerifyEmail{to: email, verify_email_url: url}
      |> VerifyEmail.render_email()

    assert mail.to == email
    assert mail.subject == "Email verification"
    assert mail.html_body =~ "verify email"
    assert mail.html_body =~ url
    assert mail.text_body =~ "verify email"
    assert mail.text_body =~ url
  end
end
