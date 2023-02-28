defmodule WeatherApiProxy.App.CitySupervisor do
  @moduledoc """
  This supervisor is responsible city child processes.
  """
  use DynamicSupervisor
  alias WeatherApiProxy.App.City

  @spec get_pid(String.t()) :: pid()
  def get_pid(city_name) do
    case start_child(city_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec start_child(String.t()) :: :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def start_child(city_name) do
    # Shorthand to retrieve the child specification from the `child_spec/1` method of the given module.
    child_specification = {City, city_name}

    DynamicSupervisor.start_child(__MODULE__, child_specification)
  end

  @impl true
  def init(_arg) do
    # :one_for_one strategy: if a child process crashes, only that process is restarted.
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
