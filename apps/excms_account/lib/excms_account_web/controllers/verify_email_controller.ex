defmodule ExcmsAccountWeb.VerifyEmailController do
  use ExcmsAccountWeb, :controller

  alias ExcmsAccountWeb.AuthService

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def edit(conn, %{"token" => token}) do
    verified = AuthService.set_email_verified(token)
    render(conn, "edit.html", verified: verified)
  end
end
