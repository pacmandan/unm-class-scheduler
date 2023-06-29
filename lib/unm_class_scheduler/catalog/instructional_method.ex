defmodule UnmClassScheduler.Catalog.InstructionalMethod do
  @behaviour UnmClassScheduler.Schema.HasConflicts
  use UnmClassScheduler.Schema

  schema "instructional_methods" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @impl true
  def conflict_keys(), do: :code
end
