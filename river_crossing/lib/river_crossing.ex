defmodule RiverCrossing do
  @type state :: :in_process | {:done, map()}

  @spec start() :: any()
  def(start()) do
    SolutionFinder.start(self())

    loop(:in_process)
  end

  @spec loop(state()) :: any()
  def loop(state) do
    receive do
      {from, :get_status} ->
        case state do
          :in_process -> send(from, :in_process)
          {:done, _solution} -> send(from, :done)
        end

        loop(state)

      {:save_solution, shipment} ->
        case state do
          :in_process ->
            loop({:done, shipment})
            shipment.history

          {:done, _} ->
            nil
        end
    end
  end
end
