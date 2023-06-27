defmodule UnmClassScheduler.Catalog.Subject do
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Child

  alias UnmClassScheduler.Catalog.Department
  alias UnmClassScheduler.Catalog.Course

  import Ecto.Changeset

  use UnmClassScheduler.Schema

  schema "subjects" do
    field :code, :string
    field :name, :string

    belongs_to :department, Department, references: :uuid, foreign_key: :department_uuid
    has_many :courses, Course, references: :uuid, foreign_key: :subject_uuid

    timestamps()
  end

  @impl true
  def validate_data(params, department: department) do
    data = %{}
    types = %{code: :string, name: :string, department_uuid: :string}
    cs = {data, types}
    |> cast(params |> Map.merge(%{department_uuid: department.uuid}), [:code, :name, :department_uuid])
    |> validate_required([:code, :name])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
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
