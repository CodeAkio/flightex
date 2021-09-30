defmodule Flightex.Bookings.Get do
  alias Flightex.Bookings.Agent, as: BookingAgent

  def call(id) do
    BookingAgent.get(id)
  end
end
