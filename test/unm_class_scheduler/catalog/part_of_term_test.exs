defmodule UnmClassScheduler.Catalog.PartOfTermTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.PartOfTerm

  doctest UnmClassScheduler.Catalog.PartOfTerm

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(PartOfTerm.serialize(nil))
    end
  end
end
