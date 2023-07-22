defmodule UnmClassScheduler.Search.BuildQuery do
  alias UnmClassScheduler.Catalog.Section

  import Ecto.Query

  def run(params) do
    params
    |> Enum.reduce(Section, &find_sections_by/2)
  end

  @spec find_sections_by({atom(), any()}, Ecto.Query.t()) :: Ecto.Query.t()
  defp find_sections_by({:semester, code}, q) do
    q
    |> join_named(:semester)
    |> where([section, semester: semester], semester.code == ^code)
  end

  defp find_sections_by({:campus, code}, q) do
    q
    |> join_named(:campus)
    |> where([section, campus: campus], campus.code == ^code)
  end

  defp find_sections_by({:subject, code}, q) do
    q
    |> join_named(:subject)
    |> where([section, subject: subject], subject.code == ^code)
  end

  defp find_sections_by({:course, number}, q) do
    q
    |> join_named(:course)
    |> where([section, course: course], course.number == ^number)
  end

  defp find_sections_by({:crn, crn}, q) do
    q
    |> where([section], section.crn == ^crn)
  end

  defp find_sections_by(_unknown_key, q), do: q

  defp join_named(q, :semester) do
    if has_named_binding?(q, :semester) do
      q
    else
      q |> join(:left, [section], semester in assoc(section, :semester), as: :semester)
    end
  end

  defp join_named(q, :campus) do
    if has_named_binding?(q, :campus) do
      q
    else
      q |> join(:left, [section], campus in assoc(section, :campus), as: :campus)
    end
  end

  defp join_named(q, :course) do
    if has_named_binding?(q, :course) do
      q
    else
      q
      |> join(:left, [section], course in assoc(section, :course), as: :course)
      |> order_by([s, course: course], asc: course.number, asc: s.number)
    end
  end

  defp join_named(q, :subject) do
    if has_named_binding?(q, :subject) do
      q
    else
      q
      |> join_named(:course)
      |> join(:left, [section, course: course], subject in assoc(course, :subject), as: :subject)
    end
  end

  # defp join_named(q, _unknown_join), do: q
end
