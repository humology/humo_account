defmodule ExcmsAccountWeb.RequireAuthenticationPlug do
  import Plug.Conn
  import Phoenix.Controller

  def init(defaults), do: defaults

  def call(conn, _defaults) do
    if conn.assigns[:current_user] == nil do
      conn
      |> put_flash(:error, "Login required")
      |> redirect(to: "/")
      |> halt()
    else
      conn
    end
  end
end
