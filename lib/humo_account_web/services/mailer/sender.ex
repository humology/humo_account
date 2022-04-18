defmodule HumoAccountWeb.Mailer.Sender do
  alias HumoAccountWeb.Mailer

  @doc "Send message"
  def send_email(%Bamboo.Email{} = mail) do
    Mailer.deliver_now(mail)
  end
end
