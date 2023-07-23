defmodule UnmClassScheduler.Catalog.PartOfTerm do
  @moduledoc """
  Represents the part of the semester a section takes place in.

  Examples include Full Term, Law Term, First Half Term, etc.
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

  schema "parts_of_term" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @impl true
  def conflict_keys(), do: :code

  @impl true
  @spec serialize(__MODULE__.t()) :: map()
  def serialize(nil), do: nil
  def serialize(data) do
    %{
      code: data.code,
      name: data.name,
    }
  end
end
