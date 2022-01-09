defmodule ExcmsAccountWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ExcmsAccountWeb, :controller
      use ExcmsAccountWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: ExcmsAccountWeb

      import Plug.Conn
      import ExcmsAccountWeb.Gettext
      # insert
      use ExcmsCoreWeb.AccessController
      # insert
      alias ExcmsCore.Permission
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/excms_account_web/templates",
        namespace: ExcmsAccountWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ExcmsAccountWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import ExcmsAccountWeb.ErrorHelpers
      import ExcmsAccountWeb.Gettext
      import ExcmsCoreWeb, only: [routes: 0]
      import ExcmsCoreWeb.AccessViewHelpers
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
