defmodule UnmClassScheduler.Catalog.BuildingTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Building
  alias UnmClassScheduler.Catalog.Campus

  doctest UnmClassScheduler.Catalog.Building

  defp setup_campus(context) do
    {:ok, campus: %Campus{uuid: context.uuid, code: "CAM", name: "Test Campus"}}
  end

  defp setup_building(context) do
    params = Map.take(context, [:code, :name, :extra])
    |> Enum.reject(fn {_, k} -> is_nil(k) end)
    |> Enum.into(%{})

    {:ok, building: params}
  end

  describe "validate_data/2" do
    @describetag uuid: "CAM12345"

    @describetag code: "BLDG"
    @describetag name: "Test Building"

    setup [:setup_campus, :setup_building]

    @tag extra: "value"
    test "when an extra parameter is provided", %{campus: campus, building: building} do
      assert Building.validate_data(building, campus: campus) ==
        {:ok, %{code: "BLDG", name: "Test Building", campus_uuid: "CAM12345"}}
    end

    @tag code: nil
    test "when code is not given", %{campus: campus, building: building} do
      assert Building.validate_data(building, campus: campus) ==
        {:error, [code: {"can't be blank", [{:validation, :required}]}]}
    end

    @tag name: nil
    test "when name is not given", %{campus: campus, building: building} do
      assert Building.validate_data(building, campus: campus) ==
        {:error, [name: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when given empty parameters", %{campus: campus} do
      assert Building.validate_data(%{}, campus: campus) ==
        {:error, [
          code: {"can't be blank", [{:validation, :required}]},
          name: {"can't be blank", [{:validation, :required}]},
        ]}
    end

    @tag uuid: nil
    test "when the parent has no uuid", %{campus: campus, building: building} do
      assert Building.validate_data(building, campus: campus) ==
        {:error, [campus_uuid: {"can't be blank", [validation: :required]}]}
    end

    test "when no parent is given", %{building: building} do
      assert Building.validate_data(building, campus: nil) ==
        {:error, [campus_uuid: {"can't be blank", [validation: :required]}]}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(Building.serialize(nil))
    end
  end
end
