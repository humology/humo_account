defmodule HumoAccount.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start a worker by calling: HumoAccount.Worker.start_link(arg)
      # {HumoAccount.Worker, arg}
    ]

    children =
      if Humo.is_otp_app_module(__MODULE__) do
        children ++
          [
            # Start the PubSub system
            {Phoenix.PubSub, name: HumoAccount.PubSub},
            # Start the Telemetry supervisor
            HumoAccountWeb.Telemetry,
            # Start the Endpoint (http/https)
            HumoAccountWeb.Endpoint
          ]
      else
        children
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HumoAccount.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HumoAccountWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
