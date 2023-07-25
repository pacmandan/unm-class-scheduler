defmodule UnmClassScheduler.Catalog.InstructorTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Instructor

  doctest UnmClassScheduler.Catalog.Instructor

  defp setup_instructor(context) do
    params = Map.take(context, [:first, :last, :middle_initial, :email, :extra])
    |> Enum.reject(fn {_, k} -> is_nil(k) end)
    |> Enum.into(%{})

    {:ok, instructor: params}
  end

  describe "validate_data/2" do
    @describetag first: "Testy"
    @describetag middle_initial: "M"
    @describetag last: "McTesterson"
    @describetag email: "test@testmail.com"

    setup [:setup_instructor]

    @tag extra: "value"
    test "when an extra parameter is provided", %{instructor: instructor} do
      assert Instructor.validate_data(instructor) ==
        {:ok, %{first: "Testy", middle_initial: "M", last: "McTesterson", email: "test@testmail.com"}}
    end

    @tag first: nil
    test "when first name is not given", %{instructor: instructor} do
      assert Instructor.validate_data(instructor) ==
        {:error, [first: {"can't be blank", [{:validation, :required}]}]}
    end

    @tag last: nil
    test "when last name is not given", %{instructor: instructor} do
      assert Instructor.validate_data(instructor) ==
        {:error, [last: {"can't be blank", [{:validation, :required}]}]}
    end

    @tag middle_initial: nil
    test "when middle initial is not given", %{instructor: instructor} do
      assert Instructor.validate_data(instructor) ==
        {:ok, %{first: "Testy", last: "McTesterson", email: "test@testmail.com"}}
    end

    @tag email: nil
    test "when email is not given", %{instructor: instructor} do
      assert Instructor.validate_data(instructor) ==
        {:error, [email: {"can't be blank", [{:validation, :required}]}]}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(Instructor.serialize(nil))
    end

    test "when given Ecto.Association.NotLoaded" do
      assert is_nil(Instructor.serialize(%Ecto.Association.NotLoaded{}))
    end
  end
end
