defmodule RiverCrossing.Data.ShipmentTest do
  use ExUnit.Case

  alias RiverCrossing.Data.Shipment

  @shipment %Shipment{
    locations: %{
      left_coast: %{cabbage: true, goat: true, wolf: true, peasant: true},
      right_coast: %{cabbage: false, goat: false, wolf: false, peasant: false}
    },
    history: %{},
    current_turn_id: 1,
    status: :new
  }

  describe "next_options" do
    assert Shipment.next_options(@shipment) == [nil, :cabbage, :goat, :wolf]
    assert Shipment.next_options(%{@shipment | status: :failure}) == []
  end

  describe "make_turn" do
    test "locations change" do
      shipment = Shipment.make_turn(@shipment, nil)

      assert shipment.locations == %{
               left_coast: %{cabbage: true, goat: true, wolf: true, peasant: false},
               right_coast: %{cabbage: false, goat: false, wolf: false, peasant: true}
             }

      shipment = Shipment.make_turn(@shipment, :goat)

      assert shipment.locations == %{
               left_coast: %{cabbage: true, goat: false, wolf: true, peasant: false},
               right_coast: %{cabbage: false, goat: true, wolf: false, peasant: true}
             }
    end

    test "log" do
      shipment =
        Shipment.make_turn(@shipment, :goat)
        |> Shipment.make_turn(nil)
        |> Shipment.make_turn(:cabbage)
        |> Shipment.make_turn(:goat)

      assert shipment.history == %{
               1 => "Go across the river with goat",
               2 => "Return to the original side",
               3 => "Go across the river with cabbage",
               4 => "Return to the original side with goat"
             }

      shipment =
        Shipment.make_turn(@shipment, :goat)
        |> Shipment.make_turn(:goat)
        |> Shipment.make_turn(:goat)

      assert shipment.history == %{
               1 => "Go across the river with goat",
               2 => "Return to the original side with goat",
               3 => "Go across the river with goat"
             }
    end

    test "check" do
      assert @shipment.status == :new

      shipment = Shipment.make_turn(@shipment, nil)

      assert shipment.status == :failure
    end
  end
end
