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

  @typedoc """
  The map structure intended for display to a user.
  Omits UUIDs and timestamps.
  """
  @type serialized_t :: %{
    code: String.t(),
    name: String.t(),
  }

  schema "instructional_methods" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> InstructionalMethod.conflict_keys()
      :code
  """
  @impl true
  @spec conflict_keys() :: atom()
  def conflict_keys(), do: :code

  @doc """
  Transforms a InstructionalMethod into a normal map intended for display to a user.

  ## Examples
      iex> InstructionalMethod.serialize(%InstructionalMethod{uuid: "IM12345", code: "IM", name: "Test IM"})
      %{code: "IM", name: "Test IM"}
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
