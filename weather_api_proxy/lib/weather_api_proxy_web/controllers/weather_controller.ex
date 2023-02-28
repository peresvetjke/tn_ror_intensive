defmodule WeatherApiProxyWeb.WeatherController do
  use Phoenix.Controller

  alias WeatherApiProxy.App
  alias WeatherApiProxy.App.City

  @spec current_weather(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def current_weather(conn, %{"city_name" => city_name} = _params) do
    case App.get_weather(city_name) do
      %City{code: :not_found} ->
        send_resp(conn, 404, "Not found")

      city ->
        send_resp(conn, 200, to_string(city.current_weather))
    end
  end
end
