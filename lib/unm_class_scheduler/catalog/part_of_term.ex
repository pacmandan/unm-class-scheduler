defmodule UnmClassScheduler.Catalog.PartOfTerm do
  @behaviour UnmClassScheduler.Schema.HasConflicts
  use UnmClassScheduler.Schema

  schema "parts_of_term" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @impl true
  def conflict_keys(), do: :code
end
