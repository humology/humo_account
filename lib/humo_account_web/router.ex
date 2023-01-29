defmodule HumoAccountWeb.Router do
  use HumoAccountWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HumoAccountWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    use HumoWeb.BrowserPlugs, otp_app: :humo_account
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :humo_dashboard do
    plug :put_root_layout, {HumoAccountWeb.LayoutView, "dashboard.html"}
  end

  scope "/", HumoAccountWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/humo", Dashboard, as: :dashboard do
      pipe_through :humo_dashboard

      get "/", PageController, :index
    end
  end

  use HumoWeb.PluginsRouter, otp_app: :humo_account

  # Other scopes may use custom stacks.
  # scope "/api", HumoAccountWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HumoAccountWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
