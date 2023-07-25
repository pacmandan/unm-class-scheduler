defmodule UnmClassScheduler.Catalog.Subject do
  @moduledoc """
  Data representing a Subject at UNM.

  UNM groups its Subjects into Departments, which are further grouped into Colleges.

  Has a uniquely identifying code and a name.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.HasParent
  @behaviour UnmClassScheduler.Schema.Serializable

  alias UnmClassScheduler.Utils.ChangesetUtils
  alias UnmClassScheduler.Catalog.Department
  alias UnmClassScheduler.Catalog.Course

  import Ecto.Changeset

  use UnmClassScheduler.Schema

  @type t :: %__MODULE__{
    uuid: String.t(),
    code: String.t(),
    name: String.t(),
    department: Department.t(),
    department_uuid: String.t(),
    courses: list(Course.t()),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @typedoc """
  The map structure intended for display to a user.
  Omits UUIDs, timestamps, and associations.
  """
  @type serialized_t :: %{
    code: String.t(),
    name: String.t()
  }

  @type valid_params :: serialized_t()

  @type valid_associations :: [
    {:department, Department.t()}
  ]

  schema "subjects" do
    field :code, :string
    field :name, :string

    belongs_to :department, Department, references: :uuid, foreign_key: :department_uuid
    has_many :courses, Course, references: :uuid, foreign_key: :subject_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  Subjects have a parent Department association. The UUID from this association
  gets applied to the input params as `:department_uuid`.

  ## Examples
      iex> Subject.validate_data(
      ...>   %{code: "SUB", name: "Test Subject"},
      ...>   department: %Department{uuid: "DEP12345"}
      ...> )
      {:ok, %{code: "SUB", name: "Test Subject", department_uuid: "DEP12345"}}

      iex> Subject.validate_data(
      ...>   %{code: "SUB", name: "Test Subject"},
      ...>   department: %Department{}
      ...> )
      {:error, [department_uuid: {"can't be blank", [validation: :required]}]}
  """
  @impl true
  @spec validate_data(valid_params(), valid_associations()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, department: department) do
    types = %{code: :string, name: :string, department_uuid: :string}
    {%{}, types}
    |> cast(params, [:code, :name])
    |> validate_required([:code, :name])
    |> ChangesetUtils.apply_association_uuids(%{department_uuid: department})
    |> ChangesetUtils.apply_if_valid()
  end

  @doc """
  Gets the parent association module for this record.
  In this case, `UnmClassScheduler.Catalog.Department`.
  This is used primarily in the updater context.

  Examples:
      iex> Subject.parent_module()
      UnmClassScheduler.Catalog.Department
  """
  @impl true
  @spec parent_module :: module()
  def parent_module(), do: Department

  @doc """
  Gets the key associated with the parent record in this record.
  This is used primarily in the updater context.

  Examples:
      iex> Subject.parent_key()
      :department
  """
  @impl true
  @spec parent_key :: atom()
  def parent_key(), do: :department

  @doc """
  Gets the parent association of this record. In this case, the parent Department.

  ## Examples
      iex> d = %Department{uuid: "12345"}
      iex> s = %Subject{uuid: "67890", department: d}
      iex> Subject.get_parent(s)
      %Department{uuid: "12345"}

      iex> Subject.get_parent(%Subject{uuid: "67890"})
      nil
  """
  @impl true
  @spec get_parent(t()) :: Department.t()
  def get_parent(subject) do
    if Ecto.assoc_loaded?(subject.department) do
      subject.department
    else
      nil
    end
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> Subject.conflict_keys()
      :code
  """
  @impl true
  @spec conflict_keys :: atom()
  def conflict_keys(), do: :code

  @doc """
  Transforms a Subject into a normal map intended for display to a user.

  ## Examples
      iex> Subject.serialize(%Subject{uuid: "SUB12345", code: "SUB", name: "Test Subject"})
      %{code: "SUB", name: "Test Subject"}
  """
  @impl true
  @spec serialize(t()) :: serialized_t()
  def serialize(nil), do: nil
  def serialize(subject) do
    %{
      code: subject.code,
      name: subject.name,
    }
  end
end
