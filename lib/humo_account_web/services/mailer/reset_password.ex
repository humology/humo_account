defmodule HumoAccountWeb.Mailer.ResetPassword do
  defstruct to: nil, reset_password_url: nil

  @config Application.compile_env!(:humo_account, HumoAccountWeb.Mailer)
  @view Keyword.fetch!(@config, :view)
  @layout Keyword.fetch!(@config, :layout)

  use Phoenix.Swoosh, view: @view, layout: @layout

  def render_email(%__MODULE__{to: to} = payload) do
    payload = Map.take(payload, [:reset_password_url])

    HumoAccountWeb.Mailer.default_email()
    |> to(to)
    |> subject("Password reset")
    |> render_body(:reset_password, payload)
  end
end
