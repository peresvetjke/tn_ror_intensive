defmodule WeatherApiProxy.App do
  @moduledoc """
  This module is our application interface.
  """

  @spec get_weather(String.t()) :: {:ok, float()} | {:error, :not_found | :unknown_error}
  def get_weather(city_name) do
    city_name
    |> WeatherApiProxy.App.City.get_weather()
  end
end
