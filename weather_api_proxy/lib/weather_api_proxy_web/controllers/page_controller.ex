defmodule WeatherApiProxyWeb.PageController do
  use WeatherApiProxyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
