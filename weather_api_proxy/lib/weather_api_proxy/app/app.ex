defmodule WeatherApiProxy.App do
  @moduledoc """
  This module is our application interface.
  """
  alias WeatherApiProxy.App.City

  @spec get_weather(String.t()) :: %City{}
  def get_weather(city_name) do
    city_name
    |> WeatherApiProxy.App.City.get_weather()
  end
end
