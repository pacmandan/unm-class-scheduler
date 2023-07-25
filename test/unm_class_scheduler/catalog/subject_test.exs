defmodule UnmClassScheduler.Catalog.SubjectTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Subject
  alias UnmClassScheduler.Catalog.Department

  doctest UnmClassScheduler.Catalog.Subject

  defp setup_department(context) do
    {:ok, department: %Department{uuid: context.uuid, code: "DEP", name: "Test Department"}}
  end

  describe "validate_data/2" do
    @describetag uuid: "DEP12345"

    setup [:setup_department]

    test "when an extra parameter is provided", %{department: department} do
      assert Subject.validate_data(%{code: "DEP", name: "Test Department", extra: "value"}, department: department) ==
        {:ok, %{code: "DEP", name: "Test Department", department_uuid: "DEP12345"}}
    end

    test "when code is not given", %{department: department} do
      assert Subject.validate_data(%{name: "Test Department"}, department: department) ==
        {:error, [code: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when name is not given", %{department: department} do
      assert Subject.validate_data(%{code: "DEP"}, department: department) ==
        {:error, [name: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when given empty parameters", %{department: department} do
      assert Subject.validate_data(%{}, department: department) ==
        {:error, [
          code: {"can't be blank", [{:validation, :required}]},
          name: {"can't be blank", [{:validation, :required}]},
        ]}
    end

    @tag uuid: nil
    test "when the parent has no uuid", %{department: department} do
      assert Subject.validate_data(%{code: "DEP", name: "Test Department"}, department: department) ==
        {:error, [department_uuid: {"can't be blank", [validation: :required]}]}
    end

    test "when no parent is given", _context do
      assert Subject.validate_data(%{code: "DEP", name: "Test Department"}, department: nil) ==
        {:error, [department_uuid: {"can't be blank", [validation: :required]}]}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(Subject.serialize(nil))
    end

    test "when given Ecto.Association.NotLoaded" do
      assert is_nil(Subject.serialize(%Ecto.Association.NotLoaded{}))
    end
  end
end
