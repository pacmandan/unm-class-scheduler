defmodule UnmClassScheduler.Catalog.Department do
  alias UnmClassScheduler.Catalog.{
    College,
    Subject
  }

  use UnmClassScheduler.Schema, conflict_keys: :code
  use UnmClassScheduler.Schema.Parent, child: :subjects
  use UnmClassScheduler.Schema.Child, parent: College

  import Ecto.Changeset

  schema "departments" do
    field :code, :string
    field :name, :string

    belongs_to :college, College, references: :uuid, foreign_key: :college_uuid
    has_many :subjects, Subject, references: :uuid, foreign_key: :department_uuid

    timestamps()
  end

  def changeset(department, attrs) do
    department
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end

  def validate(params, college) do
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

  def parent_key(), do: :college

  def parent(department), do: department.college
end
