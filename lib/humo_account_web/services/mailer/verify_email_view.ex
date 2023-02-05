defmodule HumoAccountWeb.Mailer.VerifyEmailView do
  alias HumoAccountWeb.EmailView
  alias HumoAccountWeb.Mailer

  use Phoenix.Swoosh, view: EmailView, layout: {EmailView, :layout}

  def render_email(%{user: user} = payload) do
    payload = Map.take(payload, [:verify_email_url])

    new()
    |> from(Mailer.default_from())
    |> to({user.first_name <> " " <> user.last_name, user.email})
    |> subject("Email verification")
    |> render_body(:verify_email, payload)
  end
end
