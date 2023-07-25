defmodule UnmClassScheduler.Catalog.Status do
  @moduledoc """
  The status of a particular section.

  Essentially, whether or not a status has been Cancelled, or is still Active.

  Other statuses include Inactive, Reserved, and Cancelled/Rescheduled.
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

  schema "statuses" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> Status.conflict_keys()
      :code
  """
  @impl true
  @spec conflict_keys() :: atom()
  def conflict_keys(), do: :code

  @doc """
  Transforms a Status into a normal map intended for display to a user.

  ## Examples
      iex> Status.serialize(%Status{uuid: "ST12345", code: "ST", name: "Test ST"})
      %{code: "ST", name: "Test ST"}
  """
  @impl true
  @spec serialize(t()) :: serialized_t()
  def serialize(nil), do: nil
  def serialize(data) do
    %{
      code: data.code,
      name: data.name,
    }
  end
end
