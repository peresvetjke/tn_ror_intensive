defmodule WeatherApiProxy.Repo do
  use Ecto.Repo,
    otp_app: :weather_api_proxy,
    adapter: Ecto.Adapters.Postgres
end
