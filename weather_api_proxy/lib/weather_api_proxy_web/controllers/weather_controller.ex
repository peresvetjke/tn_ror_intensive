defmodule WeatherApiProxyWeb.WeatherController do
  use Phoenix.Controller

  require Logger

  alias WeatherApiProxy.App

  @spec current_weather(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def current_weather(conn, %{"city_name" => city_name} = _params) do
    Logger.info "Proceeding request (city_name=#{city_name}) ..."

    case App.get_weather(city_name) do
      {:error, :not_found} ->
        send_resp(conn, 404, "Not found")

      {:ok, current_weather} ->
        send_resp(conn, 200, to_string(current_weather))
    end
  end
end
