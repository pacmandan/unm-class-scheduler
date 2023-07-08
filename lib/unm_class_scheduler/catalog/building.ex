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

  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils
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
      iex> UnmClassScheduler.Catalog.Building.validate_data(
      ...>   %{code: "BLDG", name: "Test Building"},
      ...>   campus: %UnmClassScheduler.Catalog.Campus{uuid: "CAM12345"}
      ...> )
      {:ok, %{code: "BLDG", name: "Test Building", campus_uuid: "CAM12345"}}

      iex> UnmClassScheduler.Catalog.Building.validate_data(
      ...>   %{code: "BLDG", name: "Test Building"},
      ...>   campus: %UnmClassScheduler.Catalog.Campus{}
      ...> )
      {:error, [campus_uuid: {"can't be blank", [validation: :required]}]}
  """
  @spec validate_data(map(), [{:campus, Campus.t()}]) :: {:ok, map()} | {:error, [{atom(), Ecto.Changeset.error()}]}
  @impl true
  def validate_data(params, campus: campus) do
    types = %{code: :string, name: :string, campus_uuid: :string}
    associations = %{campus_uuid: campus.uuid}
    {%{}, types}
    |> cast(params, [:code, :name])
    |> cast(associations, [:campus_uuid])
    |> validate_required([:code, :name, :campus_uuid])
    |> SchemaUtils.apply_changeset_if_valid()
  end

  @impl true
  def parent_module(), do: Campus

  @impl true
  def parent_key(), do: :campus

  @impl true
  def get_parent(building), do: building.campus

  @impl true
  def conflict_keys(), do: [:code, :campus_uuid]
end
