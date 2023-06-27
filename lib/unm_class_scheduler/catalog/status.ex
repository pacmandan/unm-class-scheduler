defmodule UnmClassScheduler.Catalog.Status do
  @behaviour UnmClassScheduler.Schema.HasConflicts

  use UnmClassScheduler.Schema

  schema "statuses" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @impl true
  def conflict_keys(), do: :code
end
