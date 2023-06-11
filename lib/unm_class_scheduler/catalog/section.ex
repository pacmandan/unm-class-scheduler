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

  def create_section(attrs, course, semester) do
    Ecto.build_assoc(course, :sections)
    |> cast(attrs, [:crn, :number])
    |> put_assoc(:semester, semester)
    |> validate_required([:crn, :number, :course_uuid, :semester])
    |> unique_constraint([:crn, :course_uuid, :semester])
  end
end
