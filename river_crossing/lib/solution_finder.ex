defmodule SolutionFinder do
  alias RiverCrossing.Data.Shipment

  @spec start(pid(), %Shipment{}) :: any()
  def start(river_crossing, shipment \\ %Shipment{})

  def start(river_crossing, %Shipment{status: :success} = shipment) do
    send(river_crossing, {:save_solution, shipment})
  end

  def start(river_crossing, %Shipment{} = shipment) do
    spawn_link(fn ->
      send(river_crossing, {self(), :get_status})

      receive do
        :in_process ->
          shipment
          |> Shipment.next_options()
          |> Enum.each(fn cargo ->
            start(river_crossing, Shipment.make_turn(shipment, cargo))
          end)

        {:done, _solution} ->
          nil
      end
    end)
  end
end
