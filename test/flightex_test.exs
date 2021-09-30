defmodule FlightexTest do
  use ExUnit.Case, async: true

  import Flightex.Factory

  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Users.Agent, as: UserAgent

  describe "create_or_update_user/1" do
    setup do
      Flightex.start_agents()

      :ok
    end

    test "when all params are valid, return a tuple" do
      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: "12345678900"
      }

      Flightex.create_or_update_user(params)

      {_ok, response} = UserAgent.get(params.cpf)

      expected_response = %Flightex.Users.User{
        cpf: "12345678900",
        email: "jp@banana.com",
        id: response.id,
        name: "Jp"
      }

      assert response == expected_response
    end

    test "when cpf is a integer, returns an error" do
      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: 12_345_678_900
      }

      expected_response = {:error, "Cpf must be a String"}

      response = Flightex.create_or_update_user(params)

      assert response == expected_response
    end
  end

  describe "get_booking/1" do
    setup do
      BookingAgent.start_link(%{})

      {:ok, id: UUID.uuid4()}
    end

    test "when the user is found, return a booking", %{id: id} do
      booking = build(:booking, id: id)
      {:ok, uuid} = BookingAgent.save(booking)

      response = Flightex.get_booking(uuid)

      expected_response =
        {:ok,
         %Flightex.Bookings.Booking{
           complete_date: ~N[2001-05-07 03:05:00],
           id: id,
           local_destination: "Bananeiras",
           local_origin: "Brasilia",
           user_id: "12345678900"
         }}

      assert response == expected_response
    end

    test "when the user wasn't found, returns an error", %{id: id} do
      booking = build(:booking, id: id)
      {:ok, _uuid} = BookingAgent.save(booking)

      response = Flightex.get_booking("banana")

      expected_response = {:error, "Booking not found"}

      assert response == expected_response
    end
  end

  describe "create_or_update_booking/1" do
    setup do
      BookingAgent.start_link(%{})

      :ok
    end

    test "when all params are valid, returns a valid tuple" do
      params = %{
        complete_date: ~N[2001-05-07 03:05:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_id: "e9f7d281-b9f2-467f-9b34-1b284ed58f9e"
      }

      {:ok, uuid} = Flightex.create_or_update_booking(params)

      {:ok, response} = Flightex.get_booking(uuid)

      expected_response = %Flightex.Bookings.Booking{
        id: response.id,
        complete_date: ~N[2001-05-07 03:05:00],
        local_destination: "Bananeiras",
        local_origin: "Brasilia",
        user_id: "e9f7d281-b9f2-467f-9b34-1b284ed58f9e"
      }

      assert response == expected_response
    end
  end
end
