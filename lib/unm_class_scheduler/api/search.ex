defmodule UnmClassScheduler.Api.Search do
  @moduledoc """
  Repo interface for searching for sections based on various criteria.

  May want to move this and/or change the name, not really sure where this type of module should live.
  """
  alias UnmClassScheduler.Repo
  alias UnmClassScheduler.Catalog.Section

  import Ecto.Query

  @spec find_sections(map()) :: list(map())
  def find_sections(params) do
    # q = from s in Section,
    #   left_join: sem in assoc(s, :semester),
    #   left_join: c in assoc(s, :course),
    #   left_join: campus in assoc(s, :campus),
    #   left_join: subj in assoc(c, :subject),
    #   join: mt in assoc(s, :meeting_times),
    #   left_join: bldg in assoc(mt, :building),
    #   join: is in assoc(s, :instructors),
    #   left_join: i in assoc(is, :instructor),
    #   left_join: crosslists in assoc(s, :crosslists),
    #   left_join: status in assoc(s, :status),
    #   left_join: part_of_term in assoc(s, :part_of_term),
    #   left_join: instructional_method in assoc(s, :instructional_method),
    #   left_join: delivery_type in assoc(s, :delivery_type),
    #   # Can't combine a preload with a limit.
    #   # The limit applies to _all_ loaded results, not just the Sections table.
    #   # preload: [
    #   #   semester: sem,
    #   #   campus: campus,
    #   #   course: {c, subject: subj},
    #   #   meeting_times: {mt, building: bldg},
    #   #   instructors: {is, instructor: i},
    #   #   crosslists: crosslists,
    #   #   part_of_term: part_of_term,
    #   #   status: status,
    #   #   instructional_method: instructional_method,
    #   #   delivery_type: delivery_type
    #   #   ],
    #   where: (sem.code == "202310" and subj.code == "CS" and campus.code == "ABQ"),
    #   order_by: c.number,
    #   limit: 15

    # Params are reduced and pattern matched, adding joins and wheres only as necessary.
    params
    |> Enum.reduce(Section, &find_sections_by/2)
    # TODO: Make limit and offest into opts
    |> limit([s], 15)
    |> Repo.all()
    |> Repo.preload([
      :part_of_term,
      :status,
      :delivery_type,
      :instructional_method,
      :campus,
      :semester,
      instructors: :instructor,
      meeting_times: :building,
      course: [subject: [department: :college]]
    ])
    |> Enum.map(&Section.serialize/1)
  end

  defp find_sections_by({:semester, code}, q) do
    q
    |> join_semester()
    |> where([section, semester: semester], semester.code == ^code)
  end

  defp find_sections_by({:campus, code}, q) do
    q
    |> join_campus()
    |> where([section, campus: campus], campus.code == ^code)
  end

  defp find_sections_by({:subject, code}, q) do
    q
    |> join_subject()
    |> where([section, subject: subject], subject.code == ^code)
  end

  defp find_sections_by({:course, number}, q) do
    q
    |> join_course()
    |> where([section, course: course], course.number == ^number)
  end

  defp find_sections_by(_unknown_key, q), do: q

  defp join_semester(q) do
    if has_named_binding?(q, :semester) do
      q
    else
      q |> join(:left, [section], semester in assoc(section, :semester), as: :semester)
    end
  end

  defp join_campus(q) do
    if has_named_binding?(q, :campus) do
      q
    else
      q |> join(:left, [section], campus in assoc(section, :campus), as: :campus)
    end
  end

  defp join_course(q) do
    if has_named_binding?(q, :course) do
      q
    else
      q |> join(:left, [section], course in assoc(section, :course), as: :course)
    end
  end

  defp join_subject(q) do
    if has_named_binding?(q, :subject) do
      q
    else
      q
      |> join_course()
      |> join(:left, [section, course: course], subject in assoc(course, :subject), as: :subject)
    end
  end
end
