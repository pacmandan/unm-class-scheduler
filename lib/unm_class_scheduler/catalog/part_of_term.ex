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

  @typedoc """
  The map structure intended for display to a user.
  Omits UUIDs and timestamps.
  """
  @type serialized_t :: %{
    code: String.t(),
    name: String.t(),
  }

  schema "parts_of_term" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> PartOfTerm.conflict_keys()
      :code
  """
  @impl true
  @spec conflict_keys() :: atom()
  def conflict_keys(), do: :code

  @doc """
  Transforms a PartOfTerm into a normal map intended for display to a user.

  ## Examples
      iex> PartOfTerm.serialize(%PartOfTerm{uuid: "PT12345", code: "PT", name: "Test PT"})
      %{code: "PT", name: "Test PT"}
  """
  @impl true
  @spec serialize(t()) :: serialized_t()
  def serialize(nil), do: nil
  def serialize(%Ecto.Association.NotLoaded{}), do: nil
  def serialize(data) do
    %{
      code: data.code,
      name: data.name,
    }
  end
end
