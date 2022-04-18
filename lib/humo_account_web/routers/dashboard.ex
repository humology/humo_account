defmodule HumoAccountWeb.Routers.Dashboard do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      resources "/users", HumoAccountWeb.Dashboard.UserController, except: [:new, :create]
    end
  end
end
