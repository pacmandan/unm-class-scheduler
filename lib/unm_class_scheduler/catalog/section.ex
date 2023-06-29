defmodule UnmClassScheduler.Catalog.Section do
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Catalog.{
    Semester,
    Course,
    PartOfTerm,
    Status,
    MeetingTime,
    Crosslist,
    InstructorSection,
    DeliveryType,
    InstructionalMethod,
  }

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
    belongs_to :delivery_type, DeliveryType, references: :uuid, foreign_key: :delivery_type_uuid
    belongs_to :instructional_method, InstructionalMethod, references: :uuid, foreign_key: :instructional_method_uuid

    belongs_to :semester, Semester, references: :uuid, foreign_key: :semester_uuid
    belongs_to :course, Course, references: :uuid, foreign_key: :course_uuid

    has_many :meeting_times, MeetingTime, references: :uuid, foreign_key: :section_uuid
    many_to_many :crosslists, __MODULE__, join_through: Crosslist, join_keys: [section_uuid: :uuid, crosslist_uuid: :uuid]
    # Can't do many_to_many - it would skip the "primary" field on the join table.
    # many_to_many :instructors, Instructor, join_through: InstructorSection, join_keys: [section_uuid: :uuid, instructor_uuid: :uuid]
    has_many :instructors, InstructorSection, references: :uuid, foreign_key: :section_uuid

    timestamps()
  end

  @impl true
  def validate_data(params,
      course: course,
      semester: semester,
      part_of_term: part_of_term,
      status: status,
      delivery_type: delivery_type,
      instructional_method: instructional_method
  ) do
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
      delivery_type_uuid: :string,
      instructional_method_uuid: :string,
    }

    all_params = params
    |> Map.merge(%{
      course_uuid: course.uuid,
      semester_uuid: semester.uuid,
      part_of_term_uuid: part_of_term.uuid,
      status_uuid: status.uuid,
      delivery_type_uuid: delivery_type.uuid
    })
    |> add_instructional_method(instructional_method)

    cs = {data, types}
    |> cast(all_params, Map.keys(types))
    |> validate_required([:crn, :number, :course_uuid, :semester_uuid])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end

  defp add_instructional_method(params, nil), do: params
  defp add_instructional_method(params, instructional_method) do
    params |> Map.put(:instructional_method_uuid, instructional_method.uuid)
  end

  @impl true
  def conflict_keys(), do: [:crn, :semester_uuid]
end
