defmodule HumoAccountWeb.Mailer.SenderDummy do
  @doc "Send message"
  def send_email(%Bamboo.Email{} = mail) do
    send(self(), mail)
  end
end
