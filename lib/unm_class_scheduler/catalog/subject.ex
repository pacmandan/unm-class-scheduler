defmodule UnmClassScheduler.Catalog.Subject do
  @moduledoc """
  Data representing a Subject at UNM.

  UNM groups its Subjects into Departments, which are further grouped into Colleges.

  Has a uniquely identifying code and a name.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.HasParent

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
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

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
  @spec validate_data(map(), [{:department, Department.t()}]) :: {:ok, map()} | {:error, [{atom(), Ecto.Changeset.error()}]}
  @impl true
  def validate_data(params, department: department) do
    types = %{code: :string, name: :string, department_uuid: :string}
    associations = %{department_uuid: department.uuid}
    {%{}, types}
    |> cast(params, [:code, :name])
    |> cast(associations, [:department_uuid])
    |> validate_required([:code, :name, :department_uuid])
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
end
