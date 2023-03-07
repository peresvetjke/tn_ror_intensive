defmodule WeatherApiProxy.App.City do
  @moduledoc """
  This module is responsible for caching weather info.
  """
  use GenServer
  require Logger

  alias WeatherApiProxy.App.{City, AccuWeatherApi}
  @enforce_keys [:name, :code]
  defstruct [:name, :code, :current_weather]

  @registry :city_registry

  @spec get_weather(String.t()) :: {:ok, float()} | {:error, :not_found}
  def get_weather(city_name) do
    WeatherApiProxy.App.CitySupervisor.get_pid(city_name)
    |> get_state()
    |> case do
      %City{code: :not_found} -> {:error, :not_found}
      %City{current_weather: current_weather} -> {:ok, current_weather}
    end
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

    case AccuWeatherApi.fetch_location_code(city_name) do
      {:error, :not_found} ->
        {:ok, %City{name: city_name, code: :not_found}}

      {:ok, city_code} ->
        case AccuWeatherApi.fetch_location_weather(city_code) do
          {:ok, weather} -> {:ok, %City{name: city_name, code: city_code, current_weather: weather}}
          {:error, error} -> {:error, error}
        end
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
          weather = AccuWeatherApi.fetch_location_weather(city.code)
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
end
