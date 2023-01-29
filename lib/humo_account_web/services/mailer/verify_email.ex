defmodule HumoAccountWeb.Mailer.VerifyEmail do
  defstruct [:to, :verify_email_url]

  @config Application.compile_env!(:humo_account, HumoAccountWeb.Mailer)
  @view Keyword.fetch!(@config, :view)
  @layout Keyword.fetch!(@config, :layout)

  use Phoenix.Swoosh, view: @view, layout: @layout

  def render_email(%__MODULE__{to: to} = payload) do
    payload = Map.take(payload, [:verify_email_url])

    HumoAccountWeb.Mailer.default_email()
    |> to(to)
    |> subject("Email verification")
    |> render_body(:verify_email, payload)
  end
end
