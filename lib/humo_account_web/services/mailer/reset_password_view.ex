defmodule HumoAccountWeb.Mailer.ResetPasswordView do
  alias HumoAccountWeb.EmailView
  alias HumoAccountWeb.Mailer

  use Phoenix.Swoosh, view: EmailView, layout: {EmailView, :layout}

  def render_email(%{user: user} = payload) do
    payload = Map.take(payload, [:reset_password_url])

    new()
    |> from(Mailer.default_from())
    |> to({user.first_name <> " " <> user.last_name, user.email})
    |> subject("Password reset")
    |> render_body(:reset_password, payload)
  end
end
