defmodule HumoAccountWeb.Mailer do
  use Swoosh.Mailer, otp_app: :humo_account

  def default_from, do: config!(:default_from)
  def reset_password_view, do: config!(:reset_password_view)
  def verify_email_view, do: config!(:verify_email_view)

  defp config!(key) do
    Application.fetch_env!(:humo_account, __MODULE__)
    |> Keyword.fetch!(key)
  end
end
