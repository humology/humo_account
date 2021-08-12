defmodule ExcmsAccountWeb.Routers.Dashboard do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      resources "/users", ExcmsAccountWeb.Dashboard.UserController, except: [:new, :create]
    end
  end
end
