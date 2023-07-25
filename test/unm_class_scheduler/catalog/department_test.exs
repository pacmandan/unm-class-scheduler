defmodule UnmClassScheduler.Catalog.DepartmentTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Department
  alias UnmClassScheduler.Catalog.College

  doctest UnmClassScheduler.Catalog.Department

  defp setup_college(context) do
    {:ok, college: %College{uuid: context.uuid, code: "COL", name: "Test College"}}
  end

  describe "validate_data/2" do
    @describetag uuid: "COL12345"

    setup [:setup_college]

    test "when an extra parameter is provided", %{college: college} do
      assert Department.validate_data(%{code: "DEP", name: "Test Department", extra: "value"}, college: college) ==
        {:ok, %{code: "DEP", name: "Test Department", college_uuid: "COL12345"}}
    end

    test "when code is not given", %{college: college} do
      assert Department.validate_data(%{name: "Test Department"}, college: college) ==
        {:error, [code: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when name is not given", %{college: college} do
      assert Department.validate_data(%{code: "DEP"}, college: college) ==
        {:error, [name: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when given empty parameters", %{college: college} do
      assert Department.validate_data(%{}, college: college) ==
        {:error, [
          code: {"can't be blank", [{:validation, :required}]},
          name: {"can't be blank", [{:validation, :required}]},
        ]}
    end

    @tag uuid: nil
    test "when the parent has no uuid", %{college: college} do
      assert Department.validate_data(%{code: "DEP", name: "Test Department"}, college: college) ==
        {:error, [college_uuid: {"can't be blank", [validation: :required]}]}
    end

    test "when no parent is given", _context do
      assert Department.validate_data(%{code: "DEP", name: "Test Department"}, college: nil) ==
        {:error, [college_uuid: {"can't be blank", [validation: :required]}]}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(Department.serialize(nil))
    end

    test "when given Ecto.Association.NotLoaded" do
      assert is_nil(Department.serialize(%Ecto.Association.NotLoaded{}))
    end
  end
end
