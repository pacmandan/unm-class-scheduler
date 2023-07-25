defmodule UnmClassScheduler.Catalog.Building do
  @moduledoc """
  Data representing a UNM physical building.

  However, some courses are listed as "ONLINE", so that's a building
  too I guess?

  Cannot be uniquely identified by code due to the "ONLINE" and "EDU" codes
  spanning multiple campuses. So it must be identified by both code and campus.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.HasParent
  @behaviour UnmClassScheduler.Schema.Serializable

  alias UnmClassScheduler.Utils.ChangesetUtils
  alias UnmClassScheduler.Catalog.Campus

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    uuid: String.t(),
    code: String.t(),
    name: String.t(),
    campus: Campus.t(),
    campus_uuid: String.t(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @typedoc """
  The map structure intended for display to a user.
  Omits UUIDs, timestamps, and associations.
  """
  @type serialized_t :: %{
    code: String.t(),
    name: String.t(),
  }

  @type valid_params :: serialized_t()

  @type valid_associations :: [
    {:campus, Campus.t()}
  ]

  schema "buildings" do
    field :code, :string
    field :name, :string

    belongs_to :campus, Campus, references: :uuid, foreign_key: :campus_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  Buildings have a parent Campus association. The UUID from this association
  gets applied to the input params as `:campus_uuid`.

  ## Examples
      iex> Building.validate_data(
      ...>   %{code: "BLDG", name: "Test Building"},
      ...>   campus: %Campus{uuid: "CAM12345"}
      ...> )
      {:ok, %{code: "BLDG", name: "Test Building", campus_uuid: "CAM12345"}}

      iex> Building.validate_data(
      ...>   %{code: "BLDG", name: "Test Building"},
      ...>   campus: %Campus{}
      ...> )
      {:error, [campus_uuid: {"can't be blank", [validation: :required]}]}
  """
  @impl true
  @spec validate_data(valid_params(), valid_associations()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, campus: campus) do
    types = %{code: :string, name: :string, campus_uuid: :string}
    {%{}, types}
    |> cast(params, [:code, :name])
    |> validate_required([:code, :name])
    |> ChangesetUtils.apply_association_uuids(%{campus_uuid: campus})
    |> ChangesetUtils.apply_if_valid()
  end

  @doc """
  Gets the parent association module for this record.
  In this case, `UnmClassScheduler.Catalog.Campus`.
  This is used primarily in the updater context.

  Examples:
      iex> Building.parent_module()
      UnmClassScheduler.Catalog.Campus
  """
  @impl true
  @spec parent_module :: module()
  def parent_module(), do: Campus

  @doc """
  Gets the key associated with the parent record in this record.
  This is used primarily in the updater context.

  Examples:
      iex> Building.parent_key()
      :campus
  """
  @impl true
  @spec parent_key :: atom()
  def parent_key(), do: :campus

  @doc """
  Gets the parent association of this record. In this case, the parent College.

  ## Examples
      iex> c = %Campus{uuid: "12345"}
      iex> b = %Building{uuid: "67890", campus: c}
      iex> Building.get_parent(b)
      %Campus{uuid: "12345"}

      iex> Building.get_parent(%Building{uuid: "67890"})
      nil
  """
  @impl true
  @spec get_parent(t()) :: Campus.t()
  def get_parent(building) do
    if Ecto.assoc_loaded?(building.campus) do
      building.campus
    else
      nil
    end
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> Building.conflict_keys()
      [:code, :campus_uuid]
  """
  @impl true
  @spec conflict_keys :: list(atom())
  def conflict_keys(), do: [:code, :campus_uuid]

  @doc """
  Transforms a Building into a normal map intended for display to a user.

  ## Examples
      iex> Building.serialize(%Building{uuid: "BLDG12345", code: "BLDG", name: "Test Building"})
      %{code: "BLDG", name: "Test Building"}
  """
  @impl true
  @spec serialize(t()) :: serialized_t()
  def serialize(nil), do: nil
  def serialize(building) do
    %{
      code: building.code,
      name: building.name,
    }
  end
end
