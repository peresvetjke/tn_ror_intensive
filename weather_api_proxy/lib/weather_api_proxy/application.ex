defmodule WeatherApiProxy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @registry :city_registry

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      WeatherApiProxy.Repo,
      # Start the Telemetry supervisor
      WeatherApiProxyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: WeatherApiProxy.PubSub},
      # Start the Endpoint (http/https)
      WeatherApiProxyWeb.Endpoint,
      # Start a worker by calling: WeatherApiProxy.Worker.start_link(arg)
      {WeatherApiProxy.App.CitySupervisor, []},
      {Registry, [keys: :unique, name: @registry]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherApiProxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WeatherApiProxyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
