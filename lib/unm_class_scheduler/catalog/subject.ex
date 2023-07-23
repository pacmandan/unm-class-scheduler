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

  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils
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

  @type serialized_t :: %{
    code: String.t(),
    name: String.t()
  }

  @type valid_params :: %{
    code: String.t(),
    name: String.t(),
  }

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
      iex> UnmClassScheduler.Catalog.Subject.validate_data(
      ...>   %{code: "SUB", name: "Test Subject"},
      ...>   department: %UnmClassScheduler.Catalog.Department{uuid: "DEP12345"}
      ...> )
      {:ok, %{code: "SUB", name: "Test Subject", department_uuid: "DEP12345"}}

      iex> UnmClassScheduler.Catalog.Subject.validate_data(
      ...>   %{code: "SUB", name: "Test Subject"},
      ...>   department: %UnmClassScheduler.Catalog.Department{}
      ...> )
      {:error, [department_uuid: {"can't be blank", [validation: :required]}]}
  """
  @spec validate_data(valid_params(), valid_associations()) :: SchemaUtils.maybe_valid_changes()
  @impl true
  def validate_data(params, department: department) do
    types = %{code: :string, name: :string, department_uuid: :string}
    {%{}, types}
    |> cast(params, [:code, :name])
    |> validate_required([:code, :name])
    |> SchemaUtils.apply_association_uuids(%{department_uuid: department})
    |> SchemaUtils.apply_changeset_if_valid()
  end

  @impl true
  def parent_module(), do: Department

  @impl true
  def parent_key(), do: :department

  @impl true
  def get_parent(subject), do: subject.department

  @impl true
  def conflict_keys(), do: :code

  @spec serialize(__MODULE__.t()) :: __MODULE__.serialized_t()
  @impl true
  def serialize(nil), do: nil
  def serialize(subject) do
    %{
      code: subject.code,
      name: subject.name,
    }
  end
end
