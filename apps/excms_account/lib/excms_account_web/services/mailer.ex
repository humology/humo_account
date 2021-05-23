defmodule ExcmsAccountWeb.Mailer do
  use Bamboo.Mailer, otp_app: :excms_account

  require Logger

  @from Application.get_env(:excms_account, __MODULE__)[:username]

  def send_test_email(to) do
    Logger.debug("send_test_email to=#{to}")

    Bamboo.Email.new_email(
      to: to,
      from: @from,
      subject: "Welcome to the app.",
      html_body: "<strong>Thanks for joining!</strong>",
      text_body: "Thanks for joining!"
    )
    |> deliver_now()
  end

  def send_email(message) do
    Logger.debug("send_email message=#{inspect(message)}")

    message.__struct__.render_email(message)
    |> Bamboo.Email.from(@from)
    |> deliver_now()
  end
end
