defmodule ExcmsAccount.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start a worker by calling: ExcmsAccount.Worker.start_link(arg)
      # {ExcmsAccount.Worker, arg}
    ]

    children = if ExcmsCore.server_app() == :excms_account do
      children ++ [
        # Start the PubSub system
        {Phoenix.PubSub, name: ExcmsAccount.PubSub},
        # Start the Telemetry supervisor
        ExcmsAccount.Telemetry,
        # Start the Endpoint (http/https)
        ExcmsAccount.Endpoint
      ]
    else
      children
    end

    Supervisor.start_link(children, strategy: :one_for_one, name: ExcmsAccount.Supervisor)
  end
end
