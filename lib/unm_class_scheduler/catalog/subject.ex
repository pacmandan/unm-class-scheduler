defmodule UnmClassScheduler.Catalog.Subject do
  alias UnmClassScheduler.Catalog.{
    Department,
    Course
  }

  use UnmClassScheduler.Schema, conflict_keys: :code
  use UnmClassScheduler.Schema.Parent, child: :courses
  use UnmClassScheduler.Schema.Child, parent: Department

  import Ecto.Changeset

  schema "subjects" do
    field :code, :string
    field :name, :string

    belongs_to :department, Department, references: :uuid, foreign_key: :department_uuid
    has_many :courses, Course, references: :uuid, foreign_key: :subject_uuid

    timestamps()
  end

  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end
end
