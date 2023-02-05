defmodule HumoAccountWeb.Mailer.ResetPassword do
  defstruct to: nil, reset_password_url: nil

  alias HumoAccountWeb.EmailView

  use Phoenix.Swoosh, view: EmailView, layout: {EmailView, :layout}

  def render_email(%__MODULE__{to: to} = payload) do
    payload = Map.take(payload, [:reset_password_url])

    HumoAccountWeb.Mailer.default_email()
    |> to(to)
    |> subject("Password reset")
    |> render_body(:reset_password, payload)
  end
end
