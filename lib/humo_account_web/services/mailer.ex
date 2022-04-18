defmodule HumoAccountWeb.Mailer do
  use Bamboo.Mailer, otp_app: :humo_account

  require Logger

  @mailer Application.compile_env!(:humo_account, __MODULE__)
  @from @mailer[:username]
  @sender @mailer[:sender]
  @async @mailer[:async]

  def send_test_email(to) do
    Logger.debug("send_test_email to=#{to}")

    Bamboo.Email.new_email(
      to: to,
      from: @from,
      subject: "Welcome to the app.",
      html_body: "<strong>Thanks for joining!</strong>",
      text_body: "Thanks for joining!"
    )
    |> @sender.send_email()
  end

  def send_email(message) do
    Logger.debug("send_email message=#{inspect(message)}")

    if @async do
      Task.start(fn ->
        do_send_email(message)
      end)
    else
      do_send_email(message)
    end
  end

  defp do_send_email(message) do
    Application.fetch_env!(:humo_account, message.__struct__)
    |> Keyword.fetch!(:renderer)
    |> apply(:render_email, [message])
    |> Bamboo.Email.from(@from)
    |> @sender.send_email()
  end
end
