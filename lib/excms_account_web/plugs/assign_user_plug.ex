defmodule HumoAccountWeb.AssignUserPlug do
  import Plug.Conn
  alias HumoAccountWeb.AuthService

  def init(defaults), do: defaults

  def call(conn, _defaults) do
    user_id = get_session(conn, :user_id)
    user = AuthService.get_user_by_id(user_id)

    if user != nil do
      assign(conn, :current_user, user)
    else
      conn
    end
  end
end
