defmodule ExcmsAccountWeb.MailerDummy do
  @moduledoc """
  Dummy email service
  Stores email messages in ets table
  """

  require Logger

  @doc "Send message"
  def send_email(message) do
    Logger.debug("send_email message=#{inspect(message)}")

    send(self(), message)
  end
end
