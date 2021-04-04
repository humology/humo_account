defmodule ExcmsAccountWeb.Routers.Cms do
  @moduledoc false

  defmacro __using__(_opts) do
    quote location: :keep do
      resources "/users", ExcmsAccountWeb.Cms.UserController, except: [:new, :create]
    end
  end
end
