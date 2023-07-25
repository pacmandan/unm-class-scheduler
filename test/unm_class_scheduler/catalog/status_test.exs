defmodule UnmClassScheduler.Catalog.StatusTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Status

  doctest UnmClassScheduler.Catalog.Status

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(Status.serialize(nil))
    end
  end
end
