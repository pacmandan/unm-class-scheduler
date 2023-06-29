defmodule UnmClassScheduler.Catalog.DeliveryType do
  @behaviour UnmClassScheduler.Schema.HasConflicts
  use UnmClassScheduler.Schema

  schema "delivery_types" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @impl true
  def conflict_keys(), do: :code
end
