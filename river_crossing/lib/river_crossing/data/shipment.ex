defmodule RiverCrossing.Data.Shipment do
  alias RiverCrossing.Data.Shipment

  defstruct locations: %{
              left_coast: %{cabbage: true, goat: true, wolf: true, peasant: true},
              right_coast: %{cabbage: false, goat: false, wolf: false, peasant: false}
            },
            history: %{},
            current_turn_id: 1,
            status: :new

  @spec make_turn(%Shipment{}, atom() | nil) :: %Shipment{}
  def make_turn(shipment, cargo) when shipment.status in ~w[new ongoing]a do
    shipment
    |> move(cargo)
    |> log(cargo)
    |> update_status()
    |> increment_turn_id()
  end

  @spec next_options(%Shipment{}) :: list(atom() | nil)
  def next_options(shipment) when shipment.status in ~w[failure success]a, do: []

  def next_options(shipment) when shipment.status in ~w[new ongoing]a do
    cargos =
      shipment.locations[current_location(shipment)]
      |> Enum.filter(fn {x, y} -> x != :peasant && y == true end)
      |> Enum.map(fn {x, _y} -> x end)

    [nil | cargos]
  end

  @spec update_status(%Shipment{}) :: %Shipment{}
  defp update_status(
         %Shipment{locations: %{right_coast: %{cabbage: true, goat: true, wolf: true}}} = shipment
       ),
       do: %{shipment | status: :success}

  defp update_status(%Shipment{} = shipment) do
    case valid?(shipment) do
      false ->
        %{shipment | status: :failure}

      _ ->
        new_status =
          case shipment.status do
            :new ->
              :ongoing

            _ ->
              shipment.status
          end

        %{shipment | status: new_status}
    end
  end

  @spec log(%Shipment{}, atom() | nil) :: %Shipment{}
  defp log(shipment, cargo) do
    value =
      case next_location(shipment) do
        :left_coast -> "Go across the river"
        :right_coast -> "Return to the original side"
      end

    value =
      case cargo do
        nil -> value
        smth -> value <> " with " <> to_string(smth)
      end

    %{shipment | history: Map.put(shipment.history, shipment.current_turn_id, value)}
  end

  @spec increment_turn_id(%Shipment{}) :: %Shipment{}
  defp increment_turn_id(shipment),
    do: %{shipment | current_turn_id: shipment.current_turn_id + 1}

  @spec move(%Shipment{}, atom() | nil) :: %Shipment{}
  def move(shipment, cargo)

  def move(shipment, nil) do
    [from, to] = [current_location(shipment), next_location(shipment)]
    do_move(shipment, :peasant, from, to)
  end

  def move(shipment, cargo) do
    [from, to] = [current_location(shipment), next_location(shipment)]

    do_move(shipment, cargo, from, to)
    |> do_move(:peasant, from, to)
  end

  @spec do_move(%Shipment{}, atom() | nil, atom(), atom()) :: %Shipment{}
  defp do_move(shipment = %Shipment{}, who_or_what, from, to) do
    new_locations =
      shipment.locations
      |> put_in([from, who_or_what], false)
      |> put_in([to, who_or_what], true)

    %{shipment | locations: new_locations}
  end

  @spec current_location(%Shipment{}) :: :left_coast | :right_coast
  defp current_location(%Shipment{locations: %{left_coast: %{peasant: true}}}), do: :left_coast
  defp current_location(%Shipment{locations: %{right_coast: %{peasant: true}}}), do: :right_coast

  @spec next_location(%Shipment{}) :: :left_coast | :right_coast
  defp next_location(%Shipment{locations: %{left_coast: %{peasant: true}}}), do: :right_coast
  defp next_location(%Shipment{locations: %{right_coast: %{peasant: true}}}), do: :left_coast

  @spec valid?(%Shipment{}) :: boolean()
  defp valid?(shipment) do
    shipment.locations
    |> Enum.all?(&valid_location?(&1))
  end

  @spec valid_location?(map()) :: boolean()
  defp valid_location?({_, %{peasant: false, goat: true, cabbage: true}}), do: false
  defp valid_location?({_, %{peasant: false, goat: true, wolf: true}}), do: false
  defp valid_location?(_), do: true
end
