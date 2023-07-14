defmodule UnmClassScheduler.Catalog.InstructionalMethod do
  @moduledoc """
  The method of instruction (which is different from "delivery type") for a
  particular class.

  These are things like Online, Hybrid, etc.

  A majority of courses do not have an InstructionMethod listed.
  """

  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Serializable

  use UnmClassScheduler.Schema

  @type t :: %__MODULE__{
    uuid: String.t(),
    code: String.t(),
    name: String.t(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  schema "instructional_methods" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @impl true
  def conflict_keys(), do: :code

  @spec serialize(__MODULE__.t()) :: map()
  @impl true
  def serialize(nil), do: nil
  def serialize(data) do
    %{
      code: data.code,
      name: data.name,
    }
  end
end
