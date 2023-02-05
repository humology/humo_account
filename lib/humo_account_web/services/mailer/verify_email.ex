defmodule HumoAccountWeb.Mailer.VerifyEmail do
  defstruct [:to, :verify_email_url]

  alias HumoAccountWeb.EmailView

  use Phoenix.Swoosh, view: EmailView, layout: {EmailView, :layout}

  def render_email(%__MODULE__{to: to} = payload) do
    payload = Map.take(payload, [:verify_email_url])

    HumoAccountWeb.Mailer.default_email()
    |> to(to)
    |> subject("Email verification")
    |> render_body(:verify_email, payload)
  end
end
