defmodule UnmClassScheduler.Catalog.CampusTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Campus

  doctest UnmClassScheduler.Catalog.Campus

  describe "validate_data/2" do
    test "when the parameters are strings" do
      assert Campus.validate_data(%{"code" => "CAM", "name" => "Test Campus"}) ==
        {:ok, %{code: "CAM", name: "Test Campus"}}
    end

    test "when an extra parameter is provided" do
      assert Campus.validate_data(%{code: "CAM", name: "Test Campus", extra: "value"}) ==
        {:ok, %{code: "CAM", name: "Test Campus"}}
    end

    test "when code is not given" do
      assert Campus.validate_data(%{name: "Test Campus"}) ==
        {:error, [code: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when name is not given" do
      assert Campus.validate_data(%{code: "CAM"}) ==
        {:error, [name: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when given empty parameters" do
      assert Campus.validate_data(%{}) ==
        {:error, [
          code: {"can't be blank", [{:validation, :required}]},
          name: {"can't be blank", [{:validation, :required}]},
        ]}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(Campus.serialize(nil))
    end

    test "when given Ecto.Association.NotLoaded" do
      assert is_nil(Campus.serialize(%Ecto.Association.NotLoaded{}))
    end
  end
end
