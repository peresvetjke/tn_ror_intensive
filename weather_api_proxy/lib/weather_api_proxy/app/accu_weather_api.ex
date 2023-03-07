defmodule WeatherApiProxy.App.AccuWeatherApi do
  @api_key "SA5lAHPDxgRTHoGxdUEA0vOx0SrGyEPu"

  require Logger

  @spec fetch_location_code(String.t()) :: {:error, :not_found | :unknown_error} | {:ok, any}
  def fetch_location_code(city_name) do
    Logger.info("Sending request to AccuWeather (fetch code for #{city_name})")

    case HTTPoison.get(city_code_url(city_name)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode!(body) do
          [%{"Key" => key} | _] ->
            {:ok, key}

          [] ->
            {:error, :not_found}
        end

      _ ->
        {:error, :unknown_error}
    end
  end

  @spec fetch_location_weather(String.t()) :: {:ok, float()} | {:error, :unknown_error}
  def fetch_location_weather(city_code) do
    Logger.info("Sending request to AccuWeather (fetch weather for #{city_code})")

    case HTTPoison.get(current_weather_url(city_code)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        [%{"Temperature" => %{"Metric" => %{"Value" => temperature}}}] = Poison.decode!(body)
        {:ok, temperature}

      _ ->
        {:error, :unknown_error}
    end
  end

  defp city_code_url(city_name) do
    "http://dataservice.accuweather.com/locations/v1/cities/search?apikey=#{@api_key}&q=#{city_name}"
  end

  defp current_weather_url(city_code) do
    "http://dataservice.accuweather.com/currentconditions/v1/#{city_code}?apikey=#{@api_key}"
  end
end
