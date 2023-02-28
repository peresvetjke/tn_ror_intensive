defmodule WeatherApiProxy.App.City do
  @moduledoc """
  This module is responsible for caching weather info.
  """
  use Ecto.Schema
  use GenServer
  require Logger

  alias WeatherApiProxy.App.City

  @registry :city_registry
  @api_key "SA5lAHPDxgRTHoGxdUEA0vOx0SrGyEPu"

  @primary_key false
  embedded_schema do
    field :name, :string
    field :code, :string
    field :current_weather, :float
  end

  @spec get_weather(String.t()) :: %City{}
  def get_weather(city_name) do
    WeatherApiProxy.App.CitySupervisor.get_pid(city_name)
    |> get_state()
  end

  ## GenServer API

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  @spec get_state(pid()) :: %City{}
  def get_state(pid) do
    pid
    |> GenServer.call(:get_state)
  end

  @doc """
  This function will be called by the supervisor to retrieve the specification
  of the child process.The child process is configured to restart only if it
  terminates abnormally.
  """
  def child_spec(process_name) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [process_name]},
      restart: :transient
    }
  end

  ## GenServer Callbacks

  @impl true
  def init(city_name) do
    schedule_work()
    Logger.info("Starting process #{city_name}")

    case fetch_location_code(city_name) do
      :not_found ->
        {:ok, %City{name: city_name, code: :not_found}}

      city_code ->
        weather = fetch_location_weather(city_code)
        {:ok, %City{name: city_name, code: city_code, current_weather: weather}}
    end
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:work, %City{} = city) do
    # Do the desired work here
    Logger.info("Updating weather for #{city.name}. Before: #{city.current_weather}")

    state =
      case city.name do
        :not_found ->
          city

        _ ->
          weather = fetch_location_weather(city.code)
          %City{city | current_weather: weather}
      end

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  ## Private Functions

  defp schedule_work do
    # We schedule the work to happen every hour (written in milliseconds).
    Process.send_after(self(), :work, 60 * 60 * 1000)
  end

  defp via_tuple(name),
    do: {:via, Registry, {@registry, name}}

  defp fetch_location_weather(city_code) do
    Logger.info("Sending request to AccuWeather (fetch weather for #{city_code})")

    case HTTPoison.get(current_weather_url(city_code)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        [%{"Temperature" => %{"Metric" => %{"Value" => temperature}}}] = Poison.decode!(body)
        temperature

      _ ->
        Logger.info("Something went wrong :(")
    end
  end

  defp fetch_location_code(city_name) do
    Logger.info("Sending request to AccuWeather (fetch code for #{city_name})")

    case HTTPoison.get(city_code_url(city_name)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode!(body) do
          [%{"Key" => key} | _] ->
            key

          [] ->
            Logger.info("AccuWeather can't find code for #{city_name}")
            :not_found
        end

      _ ->
        Logger.info("Something went wrong :(")
    end
  end

  defp city_code_url(city_name) do
    "http://dataservice.accuweather.com/locations/v1/cities/search?apikey=#{@api_key}&q=#{city_name}"
  end

  defp current_weather_url(city_code) do
    "http://dataservice.accuweather.com/currentconditions/v1/#{city_code}?apikey=#{@api_key}"
  end
end
