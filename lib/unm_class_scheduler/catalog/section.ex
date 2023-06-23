defmodule UnmClassScheduler.Catalog.Section do
  alias UnmClassScheduler.Catalog.{
    Semester,
    Course,
    PartOfTerm,
    Status,
  }

  use UnmClassScheduler.Schema, conflict_keys: [:crn, :semester_uuid]

  import Ecto.Changeset

  schema "sections" do
    field :crn, :string
    field :number, :string
    field :title, :string
    field :enrollment, :integer
    field :enrollment_max, :integer
    field :waitlist, :integer
    field :waitlist_max, :integer
    field :credits, :string
    field :fees, :float
    field :text, :string

    belongs_to :part_of_term, PartOfTerm, references: :uuid, foreign_key: :part_of_term_uuid
    belongs_to :status, Status, references: :uuid, foreign_key: :status_uuid

    belongs_to :semester, Semester, references: :uuid, foreign_key: :semester_uuid
    belongs_to :course, Course, references: :uuid, foreign_key: :course_uuid

    timestamps()
  end

  def create_section(attrs, course, semester, part_of_term, status) do
    Ecto.build_assoc(course, :sections)
    |> cast(attrs, [:crn, :number])
    |> put_assoc(:semester, semester)
    |> put_assoc(:part_of_term, part_of_term)
    |> put_assoc(:status, status)
    |> validate_required([:crn, :number, :course_uuid, :semester])
    |> unique_constraint([:crn, :course_uuid, :semester])
  end
end
