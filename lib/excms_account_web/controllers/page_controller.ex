defmodule ExcmsAccountWeb.PageController do
  use ExcmsAccountWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
