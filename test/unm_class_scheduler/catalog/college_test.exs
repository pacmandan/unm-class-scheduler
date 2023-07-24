defmodule UnmClassScheduler.Catalog.CollegeTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.College

  doctest UnmClassScheduler.Catalog.College

  describe "validate_data/2" do
    test "when the parameters are strings" do
      assert College.validate_data(%{"code" => "COL", "name" => "Test College"}) ==
        {:ok, %{code: "COL", name: "Test College"}}
    end

    test "when an extra parameter is provided" do
      assert College.validate_data(%{code: "COL", name: "Test College", extra: "value"}) ==
        {:ok, %{code: "COL", name: "Test College"}}
    end

    test "when code is not given" do
      assert College.validate_data(%{name: "Test College"}) ==
        {:error, [code: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when name is not given" do
      assert College.validate_data(%{code: "COL"}) ==
        {:error, [name: {"can't be blank", [{:validation, :required}]}]}
    end

    test "when given empty parameters" do
      assert College.validate_data(%{}) ==
        {:error, [
          code: {"can't be blank", [{:validation, :required}]},
          name: {"can't be blank", [{:validation, :required}]},
        ]}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(College.serialize(nil))
    end
  end
end
