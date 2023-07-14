defmodule UnmClassScheduler.Api.Search do
  @moduledoc """
  Repo interface for searching for sections based on various criteria.

  May want to move this and/or change the name, not really sure where this type of module should live.
  """
  alias UnmClassScheduler.Repo
  alias UnmClassScheduler.Catalog.Section

  import Ecto.Query

  @default_opts %{
    per_page: 10,
    page: 0,
  }

  @spec find_sections(map(), map()) :: list(map())
  def find_sections(params, opts \\ %{}) do
    # Params are reduced and pattern matched, adding joins and wheres only as necessary.
    opts = @default_opts |> Map.merge(opts) |> Map.take([:page, :per_page])
    params
    |> Enum.reduce(Section, &find_sections_by/2)
    |> limit([s], ^opts.per_page)
    |> offset(^(opts.page * opts.per_page))
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
      course: [subject: [department: :college]],
      crosslists: [course: :subject]
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

  defp find_sections_by({:crn, crn}, q) do
    q
    |> where([section], section.crn == ^crn)
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
