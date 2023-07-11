defmodule UnmClassScheduler.Catalog.Status do
  @moduledoc """
  The status of a particular section.

  Essentially, whether or not a status has been Cancelled, or is still Active.

  Other statuses include Inactive, Reserved, and Cancelled/Rescheduled.
  """

  @behaviour UnmClassScheduler.Schema.HasConflicts

  use UnmClassScheduler.Schema

  @type t :: %__MODULE__{
    uuid: String.t(),
    code: String.t(),
    name: String.t(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  schema "statuses" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @impl true
  def conflict_keys(), do: :code
end
