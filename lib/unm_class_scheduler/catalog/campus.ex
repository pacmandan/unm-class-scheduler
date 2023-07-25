defmodule UnmClassScheduler.Catalog.Campus do
  @moduledoc """
  Data representing a particular UNM campus location.

  This does not necessarily represent a physical location, as
  UNM has an "Online & ITV" campus for fully online classes.

  Has a uniquely identifying code and a name.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Serializable

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Utils.ChangesetUtils
  alias UnmClassScheduler.Catalog.Building

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

  @type valid_params :: serialized_t()

  schema "campuses" do
    field :code, :string
    field :name, :string

    has_many :buildings, Building, references: :uuid, foreign_key: :campus_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  Campuses have no parent associations, so any second parameter to `validate_data/2` is ignored.

  Required parameters are `:code` and `:name`.

  ## Examples
      iex> Campus.validate_data(%{code: "CAM", name: "Test Campus"})
      {:ok, %{code: "CAM", name: "Test Campus"}}

      iex> Campus.validate_data(%{code: "CAM"})
      {:error, [name: {"can't be blank", [{:validation, :required}]}]}
  """
  @impl true
  @spec validate_data(valid_params(), any()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, _associations \\ []) do
    types = %{code: :string, name: :string}

    {%{}, types}
    |> cast(params, [:code, :name])
    |> validate_required([:code, :name])
    |> ChangesetUtils.apply_if_valid()
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> Campus.conflict_keys()
      :code
  """
  @impl true
  @spec conflict_keys() :: atom()
  def conflict_keys(), do: :code

  @doc """
  Transforms a Campus into a normal map intended for display to a user.

  ## Examples
      iex> Campus.serialize(%Campus{uuid: "CAM12345", code: "CAM", name: "Test Campus"})
      %{code: "CAM", name: "Test Campus"}
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
