defmodule HumoAccountWeb.Mailer.ResetPassword do
  defstruct to: nil, reset_password_url: nil

  use Bamboo.Phoenix, view: HumoAccountWeb.EmailView

  def render_email(%__MODULE__{to: to} = payload) do
    new_email()
    |> put_html_layout({HumoAccountWeb.LayoutView, "email.html"})
    |> to(to)
    |> subject("Password reset")
    |> assign(:reset_password_url, payload.reset_password_url)
    |> render(:reset_password)
  end
end
