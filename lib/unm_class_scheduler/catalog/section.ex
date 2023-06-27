defmodule UnmClassScheduler.Catalog.Section do
  alias UnmClassScheduler.Catalog.{
    Semester,
    Course,
    PartOfTerm,
    Status,
    MeetingTime,
    Crosslist,
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

    has_many :meeting_times, MeetingTime, references: :uuid, foreign_key: :section_uuid
    many_to_many :crosslists, __MODULE__, join_through: Crosslist, join_keys: [section_uuid: :uuid, crosslist_uuid: :uuid]

    timestamps()
  end

  def create_section(attrs, course, semester, part_of_term, status) do
    Ecto.build_assoc(course, :sections)
    |> cast(attrs, [:crn, :number, :enrollment, :enrollment_max, :waitlist, :waitlist_max, :credits, :fees, :text, :title])
    |> put_assoc(:semester, semester)
    |> put_assoc(:part_of_term, part_of_term)
    |> put_assoc(:status, status)
    |> validate_required([:crn, :number, :course_uuid, :semester])
    |> unique_constraint([:crn, :course_uuid, :semester])
  end

  def validate(params, course, semester, part_of_term, status) do
    data = %{}
    types = %{
      crn: :string,
      number: :string,
      title: :string,
      enrollment: :integer,
      enrollment_max: :integer,
      waitlist: :integer,
      waitlist_max: :integer,
      credits: :string,
      fees: :float,
      text: :string,
      course_uuid: :string,
      semester_uuid: :string,
      part_of_term_uuid: :string,
      status_uuid: :string,
    }
    all_params = params
    |> Map.merge(%{
      course_uuid: course.uuid,
      semester_uuid: semester.uuid,
      part_of_term_uuid: part_of_term.uuid,
      status_uuid: status.uuid
    })
    cs = {data, types}
    |> cast(all_params, Map.keys(types))
    |> validate_required([:crn, :number, :course_uuid, :semester_uuid])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end
end
