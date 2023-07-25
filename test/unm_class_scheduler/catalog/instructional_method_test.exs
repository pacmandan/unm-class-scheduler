defmodule UnmClassScheduler.Catalog.InstructionalMethodTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.InstructionalMethod

  doctest UnmClassScheduler.Catalog.InstructionalMethod

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(InstructionalMethod.serialize(nil))
    end

    test "when given Ecto.Association.NotLoaded" do
      assert is_nil(InstructionalMethod.serialize(%Ecto.Association.NotLoaded{}))
    end
  end
end
