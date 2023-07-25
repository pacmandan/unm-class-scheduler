defmodule UnmClassScheduler.Catalog.Department do
  @moduledoc """
  Data representing a particular "Department" at UNM.

  UNM groups its Subjects into Departments, which are further grouped into Colleges.

  Has a uniquely identifying code and a name.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.HasParent
  @behaviour UnmClassScheduler.Schema.Serializable

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Utils.ChangesetUtils
  alias UnmClassScheduler.Catalog.College
  alias UnmClassScheduler.Catalog.Subject

  @type t :: %__MODULE__{
    uuid: String.t(),
    code: String.t(),
    name: String.t(),
    college: College.t(),
    college_uuid: String.t(),
    subjects: list(Subject.t()),
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
    {:college, College.t()}
  ]

  schema "departments" do
    field :code, :string
    field :name, :string

    belongs_to :college, College, references: :uuid, foreign_key: :college_uuid
    has_many :subjects, Subject, references: :uuid, foreign_key: :department_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.=

  Departments have a parent College association. The UUID from this association
  gets applied to the input params as `:college_uuid`.

  ## Examples
      iex> Department.validate_data(
      ...>   %{code: "DEP", name: "Test Department"},
      ...>   college: %College{uuid: "COL12345"}
      ...> )
      {:ok, %{code: "DEP", name: "Test Department", college_uuid: "COL12345"}}

      iex> Department.validate_data(
      ...>   %{code: "DEP", name: "Test Department"},
      ...>   college: %College{}
      ...> )
      {:error, [college_uuid: {"can't be blank", [validation: :required]}]}
  """
  @impl true
  @spec validate_data(valid_params(), valid_associations()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, college: college) do
    types = %{code: :string, name: :string, college_uuid: :string}
    {%{}, types}
    |> cast(params, [:code, :name])
    |> validate_required([:code, :name])
    |> ChangesetUtils.apply_association_uuids(%{college_uuid: college})
    |> ChangesetUtils.apply_if_valid()
  end

  @doc """
  Gets the parent association module for this record.
  In this case, `UnmClassScheduler.Catalog.College`.
  This is used primarily in the updater context.

  Examples:
      iex> Department.parent_module()
      UnmClassScheduler.Catalog.College
  """
  @impl true
  @spec parent_module :: module()
  def parent_module(), do: College

  @doc """
  Gets the key associated with the parent record in this record.
  This is used primarily in the updater context.

  Examples:
      iex> Department.parent_key()
      :college
  """
  @impl true
  @spec parent_key :: atom()
  def parent_key(), do: :college

  @doc """
  Gets the parent association of this record. In this case, the parent College.

  ## Examples
      iex> c = %College{uuid: "12345"}
      iex> d = %Department{uuid: "67890", college: c}
      iex> Department.get_parent(d)
      %College{uuid: "12345"}

      iex> Department.get_parent(%Department{uuid: "67890"})
      nil
  """
  @impl true
  @spec get_parent(t()) :: College.t()
  def get_parent(department) do
    if Ecto.assoc_loaded?(department.college) do
      department.college
    else
      nil
    end
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> Department.conflict_keys()
      :code
  """
  @impl true
  @spec conflict_keys :: atom()
  def conflict_keys(), do: :code

  @doc """
  Transforms a Department into a normal map intended for display to a user.

  ## Examples
      iex> Department.serialize(%Department{uuid: "DEP12345", code: "DEP", name: "Test Department"})
      %{code: "DEP", name: "Test Department"}
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
