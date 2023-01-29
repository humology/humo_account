defmodule HumoAccountWeb.Mailer do
  use Swoosh.Mailer, otp_app: :humo_account
  import Swoosh.Email

  def default_email do
    new()
    |> from({"Name", "test@example.com"})
  end
end
