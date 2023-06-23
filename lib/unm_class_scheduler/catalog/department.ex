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
end
