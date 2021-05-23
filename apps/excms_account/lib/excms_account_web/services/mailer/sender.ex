defmodule ExcmsAccountWeb.Mailer.Sender do
  alias ExcmsAccountWeb.Mailer

  @doc "Send message"
  def send_email(%Bamboo.Email{} = mail) do
    Mailer.deliver_now(mail)
  end
end
