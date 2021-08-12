defmodule ExcmsAccountWeb.Mailer.VerifyEmail do
  defstruct to: nil, email_verified_url: nil

  use Bamboo.Phoenix, view: ExcmsAccountWeb.EmailView

  def render_email(%__MODULE__{to: to} = payload) do
    new_email()
    |> put_html_layout({ExcmsAccountWeb.LayoutView, "email.html"})
    |> to(to)
    |> subject("Email verification")
    |> assign(:email_verified_url, payload.email_verified_url)
    |> render(:verify_email)
  end
end