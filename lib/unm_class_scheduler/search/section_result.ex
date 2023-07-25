defmodule UnmClassScheduler.Search.SectionResult do
  @moduledoc """
  Result data when performing a search.

  This is essentially a Section, and _all_ associated resources,
  as deeply nested as we can go without recursion.

  This is the data used to display a sections information on the frontend.
  """

  alias UnmClassScheduler.Utils.MapUtils
  alias UnmClassScheduler.Catalog.Semester
  alias UnmClassScheduler.Catalog.Campus
  alias UnmClassScheduler.Catalog.Course
  alias UnmClassScheduler.Catalog.PartOfTerm
  alias UnmClassScheduler.Catalog.Status
  alias UnmClassScheduler.Catalog.MeetingTime
  alias UnmClassScheduler.Catalog.Instructor
  alias UnmClassScheduler.Catalog.DeliveryType
  alias UnmClassScheduler.Catalog.InstructionalMethod
  alias UnmClassScheduler.Catalog.Subject
  alias UnmClassScheduler.Catalog.Department
  alias UnmClassScheduler.Catalog.College

  @type coded_result_t :: %{code: String.t(), name: String.t()}
  @type t :: %{
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
    course: %{
      number: String.t(),
      title: String.t(),
      catalog_description: String.t(),
    },
    subject: coded_result_t(),
    department: coded_result_t(),
    college: coded_result_t(),
    semester: coded_result_t(),
    campus: coded_result_t(),
    part_of_term: coded_result_t(),
    status: coded_result_t(),
    delivery_type: coded_result_t(),
    instructional_method: coded_result_t(),
    instructors: list(%{
      primary: boolean(),
      first: String.t(),
      last: String.t(),
      middle_initial: String.t(),
      email: String.t(),
    }),
    meeting_times: list(%{
      start_date: Date.t(),
      end_date: Date.t(),
      start_time: Time.t(),
      end_time: Time.t(),
      sunday: boolean(),
      monday: boolean(),
      tuesday: boolean(),
      wednesday: boolean(),
      thursday: boolean(),
      friday: boolean(),
      saturday: boolean(),
      room: String.t(),
      building: coded_result_t(),
      building_uuid: String.t(),
    }),
    crosslists: list(%{
      crn: String.t(),
      course_number: String.t(),
      subject_code: String.t(),
    })
  }

  @doc """
  Takes a section and builds out the associated Result.

  If an association is nil, that association will be nil in the result.
  So PRELOADS MUST HAPPEN BEFORE CALLING THIS if you want associations included.
  """
  @spec build(Section.t()) :: Result.t()
  def build(section) do
    %{
      crn: section.crn,
      number: section.number,
      title: section.title,
      enrollment: section.enrollment,
      enrollment_max: section.enrollment_max,
      waitlist: section.waitlist,
      waitlist_max: section.waitlist_max,
      credits_min: section.credits_min,
      credits_max: section.credits_max,
      fees: section.fees,
      text: section.text,
      semester: Semester.serialize(section.semester),
      campus: Campus.serialize(section.campus),
      course: Course.serialize(section.course),
      subject: Subject.serialize(MapUtils.maybe(section, [:course, :subject])),
      department: Department.serialize(MapUtils.maybe(section, [:course, :subject, :department])),
      college: College.serialize(MapUtils.maybe(section, [:course, :subject, :department, :college])),
      part_of_term: PartOfTerm.serialize(section.part_of_term),
      status: Status.serialize(section.status),
      delivery_type: DeliveryType.serialize(section.delivery_type),
      instructional_method: InstructionalMethod.serialize(section.instructional_method),
      instructors: Enum.map(empty_array_if_not_loaded(section.instructors), fn instructor_section ->
        %{primary: instructor_section.primary}
        |> Map.merge(Instructor.serialize(instructor_section.instructor))
      end),
      meeting_times: Enum.map(empty_array_if_not_loaded(section.meeting_times), &MeetingTime.serialize/1),
      crosslists: Enum.map(empty_array_if_not_loaded(section.crosslists), fn s ->
        %{
          crn: s.crn,
          course_number: Course.serialize(s.course),
          subject_code: Subject.serialize(MapUtils.maybe(s, [:course, :subject]))
        }
      end),
    }
  end

  defp empty_array_if_not_loaded(%Ecto.Association.NotLoaded{}), do: []
  defp empty_array_if_not_loaded(data) when is_list(data), do: data
end
