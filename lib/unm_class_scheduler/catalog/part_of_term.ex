defmodule UnmClassScheduler.Catalog.PartOfTerm do
  use UnmClassScheduler.Schema

  schema "parts_of_term" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  # Not sure we need a changeset here?
  # These are static fields that will only update via seeds and migrations.
end
