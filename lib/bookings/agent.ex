defmodule Flightex.Bookings.Agent do
  alias Flightex.Bookings.Booking

  def start_link(initial_state \\ %{}) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def save(%Booking{} = booking) do
    Agent.update(__MODULE__, &update_state(&1, booking))

    {:ok, booking.id}
  end

  def get(uuid) do
    Agent.get(__MODULE__, &get_booking(&1, uuid))
  end

  defp get_booking(state, uuid) do
    case Map.get(state, uuid) do
      nil -> {:error, "Booking not found"}
      booking -> {:ok, booking}
    end
  end

  defp update_state(state, booking) do
    Map.put(state, booking.id, booking)
  end
end
