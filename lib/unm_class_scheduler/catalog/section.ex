defmodule UnmClassScheduler.Catalog.Section do
  @moduledoc """
  Data representing a Section at UNM.

  A Section is an actual "class" that happens. It has a specific time, place,
  and course that it covers, as well as someone who is teaching it.
  When scheduling, these are the main "things" you are choosing from.

  Serialization for Sections has been moved to `UnmClassScheduler.Search.SectionResult`,
  since it is so large and encompasses things well beyond the scope of just Sections.
  """
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  alias UnmClassScheduler.Utils.ChangesetUtils
  alias UnmClassScheduler.Catalog.Semester
  alias UnmClassScheduler.Catalog.Campus
  alias UnmClassScheduler.Catalog.Course
  alias UnmClassScheduler.Catalog.PartOfTerm
  alias UnmClassScheduler.Catalog.Status
  alias UnmClassScheduler.Catalog.MeetingTime
  alias UnmClassScheduler.Catalog.Crosslist
  alias UnmClassScheduler.Catalog.InstructorSection
  alias UnmClassScheduler.Catalog.DeliveryType
  alias UnmClassScheduler.Catalog.InstructionalMethod

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    uuid: String.t(),
    crn: String.t(),
    number: String.t(),
    title: String.t(),
    enrollment: integer(),
    enrollment_max: integer(),
    waitlist: integer(),
    waitlist_max: integer(),
    credits: String.t(),
    credits_min: integer(),
    credits_max: integer(),
    fees: float(),
    text: String.t(),
    course: Course.t(),
    course_uuid: String.t(),
    semester: Semester.t(),
    semester_uuid: String.t(),
    campus: Campus.t(),
    campus_uuid: String.t(),
    part_of_term: PartOfTerm.t(),
    part_of_term_uuid: String.t(),
    status: Status.t(),
    status_uuid: String.t(),
    delivery_type: DeliveryType.t(),
    delivery_type_uuid: String.t(),
    instructional_method: InstructionalMethod.t(),
    instructional_method_uuid: String.t(),
    instructors: list(InstructorSection.t()),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @type valid_params :: %{
    crn: String.t(),
    number: String.t(),
    title: String.t(),
    enrollment: integer(),
    enrollment_max: integer(),
    waitlist: integer(),
    waitlist_max: integer(),
    credits: String.t(),
    credits_min: integer(),
    credits_max: integer(),
    fees: float(),
    text: String.t(),
  }

  @type valid_associations :: [
    course: Course.t(),
    semester: Semester.t(),
    part_of_term: PartOfTerm.t(),
    status: Status.t(),
    delivery_type: DeliveryType.t(),
    instructional_method: InstructionalMethod.t(),
    campus: Campus.t()
  ]

  schema "sections" do
    field :crn, :string
    field :number, :string
    field :title, :string
    field :enrollment, :integer
    field :enrollment_max, :integer
    field :waitlist, :integer
    field :waitlist_max, :integer
    field :credits, :string
    field :credits_min, :integer
    field :credits_max, :integer
    field :fees, :float
    field :text, :string

    belongs_to :part_of_term, PartOfTerm, references: :uuid, foreign_key: :part_of_term_uuid
    belongs_to :status, Status, references: :uuid, foreign_key: :status_uuid
    belongs_to :delivery_type, DeliveryType, references: :uuid, foreign_key: :delivery_type_uuid
    belongs_to :instructional_method, InstructionalMethod, references: :uuid, foreign_key: :instructional_method_uuid

    belongs_to :semester, Semester, references: :uuid, foreign_key: :semester_uuid
    belongs_to :course, Course, references: :uuid, foreign_key: :course_uuid
    belongs_to :campus, Campus, references: :uuid, foreign_key: :campus_uuid

    has_many :meeting_times, MeetingTime, references: :uuid, foreign_key: :section_uuid
    many_to_many :crosslists, __MODULE__, join_through: Crosslist, join_keys: [section_uuid: :uuid, crosslist_uuid: :uuid]
    # Can't do many_to_many - it would skip the "primary" field on the join table.
    # many_to_many :instructors, Instructor, join_through: InstructorSection, join_keys: [section_uuid: :uuid, instructor_uuid: :uuid]
    has_many :instructors, InstructorSection, references: :uuid, foreign_key: :section_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  ## Examples
      iex> associations = %{
      ...>   course: %Course{uuid: "C12345"},
      ...>   semester: %Semester{uuid: "SEM12345"},
      ...>   campus: %Campus{uuid: "CAM12345"},
      ...>   part_of_term: %PartOfTerm{uuid: "PT12345"},
      ...>   status: %Status{uuid: "ST12345"},
      ...>   delivery_type: %DeliveryType{uuid: "DT12345"},
      ...>   instructional_method: %InstructionalMethod{uuid: "IM12345"},
      ...> }
      iex> params = %{crn: "58001", number: "0001", title: "Test Section"}
      iex> Section.validate_data(params, associations)
      {:ok, %{
        crn: "58001", number: "0001", title: "Test Section",
        course_uuid: "C12345",
        semester_uuid: "SEM12345",
        campus_uuid: "CAM12345",
        part_of_term_uuid: "PT12345",
        status_uuid: "ST12345",
        delivery_type_uuid: "DT12345",
        instructional_method_uuid: "IM12345",
      }}
  """
  @impl true
  @spec validate_data(valid_params(), valid_associations()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, associations) do
    types = %{
      crn: :string,
      number: :string,
      title: :string,
      enrollment: :integer,
      enrollment_max: :integer,
      waitlist: :integer,
      waitlist_max: :integer,
      credits: :string,
      credits_min: :integer,
      credits_max: :integer,
      fees: :float,
      text: :string,
      course_uuid: :string,
      semester_uuid: :string,
      campus_uuid: :string,
      part_of_term_uuid: :string,
      status_uuid: :string,
      delivery_type_uuid: :string,
      instructional_method_uuid: :string,
    }
    required_associations = %{
      course_uuid: associations[:course],
      semester_uuid: associations[:semester],
      campus_uuid: associations[:campus],
    }
    optional_associtaions = %{
      part_of_term_uuid: associations[:part_of_term],
      status_uuid: associations[:status],
      delivery_type_uuid: associations[:delivery_type],
      instructional_method_uuid: associations[:instructional_method],
    }

    {%{}, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:crn, :number])
    |> ChangesetUtils.apply_association_uuids(required_associations, optional_associtaions)
    |> ChangesetUtils.apply_if_valid()
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> Section.conflict_keys()
      [:crn, :semester_uuid]
  """
  @impl true
  @spec conflict_keys() :: list(atom())
  def conflict_keys(), do: [:crn, :semester_uuid]
end
