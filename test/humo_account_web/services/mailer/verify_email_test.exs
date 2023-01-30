defmodule HumoAccountWeb.Mailer.VerifyEmailTest do
  use ExUnit.Case
  alias HumoAccountWeb.Mailer.VerifyEmail

  test "password reset email" do
    user_email = "user@mail.invalid"
    url = "http://verify_email_url"

    email =
      %VerifyEmail{to: user_email, verify_email_url: url}
      |> VerifyEmail.render_email()

    assert email.to == [{"", user_email}]
    assert email.subject == "Email verification"
    assert email.html_body =~ "verify email"
    assert email.html_body =~ url
    assert email.text_body =~ "verify email"
    assert email.text_body =~ url
  end
end
