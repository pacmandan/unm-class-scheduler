defmodule UnmClassScheduler.Catalog.Section do
  use UnmClassScheduler.Schema

  alias UnmClassScheduler.Catalog.{
    Semester,
    Course,
  }

  import Ecto.Changeset

  schema "sections" do
    field :crn, :string
    field :number, :string

    belongs_to :semester, Semester, references: :uuid, foreign_key: :semester_uuid
    belongs_to :course, Course, references: :uuid, foreign_key: :course_uuid

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:crn, :number])
    |> validate_required([:crn, :number, :course_uuid, :semester_uuid])
    |> unique_constraint([:crn, :course_uuid, :semester_uuid])
  end
end
