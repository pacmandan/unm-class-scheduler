defmodule UnmClassScheduler.Catalog.SemesterTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Semester

  doctest UnmClassScheduler.Catalog.Semester

  describe "validate_data/2" do
    test "when the parameters are strings" do
      assert Semester.validate_data(%{"code" => "TEST", "name" => "Test Semester"}) ==
        {:ok, %{code: "TEST", name: "Test Semester"}}
    end

    test "when an extra parameter is provided" do
      assert Semester.validate_data(%{code: "TEST", name: "Test Semester", extra: "value"}) ==
        {:ok, %{code: "TEST", name: "Test Semester"}}
    end

    test "when code is not given" do
      assert Semester.validate_data(%{name: "Test Semester"}) ==
        {:error, [code: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when name is not given" do
      assert Semester.validate_data(%{code: "TEST"}) ==
        {:error, [name: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when given empty parameters" do
      assert Semester.validate_data(%{}) ==
        {:error, [
          code: {"can't be blank", [{:validation, :required}]},
          name: {"can't be blank", [{:validation, :required}]},
        ]}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(Semester.serialize(nil))
    end

    test "when given Ecto.Association.NotLoaded" do
      assert is_nil(Semester.serialize(%Ecto.Association.NotLoaded{}))
    end
  end
end
