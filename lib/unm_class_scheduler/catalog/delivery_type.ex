defmodule UnmClassScheduler.Catalog.DeliveryType do
  @moduledoc """
  Represents the type of class a particular section represents.

  Examples include Lecture, Thesis, and Studio.
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

  schema "delivery_types" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @impl true
  def conflict_keys(), do: :code
end
