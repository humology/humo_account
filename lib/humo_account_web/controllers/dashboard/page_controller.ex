defmodule HumoAccountWeb.Dashboard.PageController do
  use HumoAccountWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", page_title: "Overview")
  end
end
