defmodule UnmClassScheduler.Catalog.DeliveryTypeTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.DeliveryType

  doctest UnmClassScheduler.Catalog.DeliveryType

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(DeliveryType.serialize(nil))
    end

    test "when given Ecto.Association.NotLoaded" do
      assert is_nil(DeliveryType.serialize(%Ecto.Association.NotLoaded{}))
    end
  end
end
