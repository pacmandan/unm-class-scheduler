defmodule UnmClassScheduler.Catalog.DeliveryType do
  @moduledoc """
  Represents the type of class a particular section represents.

  Examples include Lecture, Thesis, and Studio.
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

  schema "delivery_types" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> DeliveryType.conflict_keys()
      :code
  """
  @impl true
  @spec conflict_keys() :: atom()
  def conflict_keys(), do: :code

  @doc """
  Transforms a DeliveryType into a normal map intended for display to a user.

  ## Examples
      iex> DeliveryType.serialize(%DeliveryType{uuid: "DT12345", code: "DT", name: "Test DT"})
      %{code: "DT", name: "Test DT"}
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
