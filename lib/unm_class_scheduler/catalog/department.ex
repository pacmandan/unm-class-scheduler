defmodule UnmClassScheduler.Catalog.Department do
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Child

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Catalog.College
  alias UnmClassScheduler.Catalog.Subject

  schema "departments" do
    field :code, :string
    field :name, :string

    belongs_to :college, College, references: :uuid, foreign_key: :college_uuid
    has_many :subjects, Subject, references: :uuid, foreign_key: :department_uuid

    timestamps()
  end

  @impl true
  def validate_data(params, college: college) do
    data = %{}
    types = %{code: :string, name: :string, college_uuid: :string}
    cs = {data, types}
    |> cast(params |> Map.merge(%{college_uuid: college.uuid}), [:code, :name, :college_uuid])
    |> validate_required([:code, :name])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end

  @impl true
  def parent_module(), do: College

  @impl true
  def parent_key(), do: :college

  @impl true
  def get_parent(department), do: department.college

  @impl true
  def conflict_keys(), do: :code
end
