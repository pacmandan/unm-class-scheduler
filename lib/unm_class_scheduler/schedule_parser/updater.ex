defmodule UnmClassScheduler.ScheduleParser.Updater do
  alias UnmClassScheduler.Repo
  alias UnmClassScheduler.ScheduleParser.EventHandler
  alias UnmClassScheduler.Catalog.{
    Semester,
    Campus,
    Building,
    College,
    Department,
    Subject,
    Course,
    Section,
    PartOfTerm,
    Status,
  }

  import Ecto.Query

  def load_from_file(filename) do
    stream = File.stream!(Path.expand(filename))
    {:ok, extracted} = Saxy.parse_stream(stream, EventHandler, %{})
    mass_insert(extracted)
  end

  def mass_insert(extracted_attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(
      :parts_of_term,
      fetch_coded_and_cache_all(PartOfTerm)
    )
    |> Ecto.Multi.run(
      :statuses,
      fetch_coded_and_cache_all(Status)
    )
    |> Ecto.Multi.run(
      Semester,
      insert_coded_schema(extracted_attrs[:semesters], Semester)
    )
    |> Ecto.Multi.run(
      Campus,
      insert_coded_schema(extracted_attrs[:campuses], Campus)
    )
    |> Ecto.Multi.run(
      Building,
      insert_linked_coded_schema(extracted_attrs[:buildings], Building, &building_key/2)
    )
    |> Ecto.Multi.run(
      College,
      insert_coded_schema(extracted_attrs[:colleges], College)
    )
    |> Ecto.Multi.run(
      Department,
      insert_linked_coded_schema(extracted_attrs[:departments], Department)
    )
    |> Ecto.Multi.run(
      Subject,
      insert_linked_coded_schema(extracted_attrs[:subjects], Subject)
    )
    |> Ecto.Multi.run(
      Course,
      insert_linked_coded_schema(extracted_attrs[:courses], Course, &course_key/2)
      #insert_courses(extracted_attrs[:courses])
    )
    |> Ecto.Multi.run(
      Section,
      insert_section(extracted_attrs[:sections])
    )
    |> Repo.transaction(timeout: 60_000)
  end

  defp repo_insert(changeset, repo, conflict_target) do
    repo.insert!(
      changeset,
      on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
      conflict_target: conflict_target,
      returning: true
    )
  end

  defp fetch_coded_and_cache_all(schema) do
    fn repo, _cache ->
      repo.all(from(schema))
      |> Enum.reduce(%{}, fn m, acc ->
        Map.put(acc, m.code, m)
      end)
      |> (&({:ok, &1})).()
    end
  end

  defp get_code(i) do
    i.code
  end

  defp get_code(i, _p) do
    i.code
  end

  defp building_key(building, campus) do
    building_code(campus.code, building.code)
  end

  defp course_key(course, subject) do
    course_code(subject.code, course.number)
  end

  defp course_code(subject_code, course_number) do
    "#{subject_code}__#{course_number}"
  end

  defp building_code(campus_code, building_code) do
    "#{campus_code}__#{building_code}"
  end

  # Semester, Campus, College
  defp insert_coded_schema(attrs_to_insert, schema, cache_key_fn \\ &get_code/1) do
    fn repo, _cache ->
      Enum.map(attrs_to_insert, fn {_, attrs} ->
        struct(schema)
        |> schema.changeset(attrs)
        |> repo_insert(repo, schema.conflict_keys())
        |> (&({cache_key_fn.(&1), &1})).()
      end)
      |> Enum.into(%{})
      |> (&({:ok, &1})).()
    end
  end

  # Department, Subject, Building, Course
  defp insert_linked_coded_schema(attrs_to_insert, schema, cache_key_fn \\ &get_code/2) do
    fn repo, cache ->
      Enum.map(attrs_to_insert, fn {_, attrs} ->
        with {parent_attrs, attrs} <- attrs |> Map.pop(schema.parent_module()),
          parent <- get_in(cache, [schema.parent_module(), parent_attrs[:code]])
        do
          parent
          |> schema.parent_module().new_child()
          |> schema.changeset(attrs)
          |> repo_insert(repo, schema.conflict_keys())
          |> (&({cache_key_fn.(&1, parent), &1})).()
        end
      end)
      |> Enum.into(%{})
      |> (&({:ok, &1})).()
    end
  end

  # Section
  defp insert_section(attrs_to_insert) do
    fn repo, cache ->
      Enum.map(attrs_to_insert, fn {_, attrs} ->
        with {subject_attrs, attrs} <- attrs |> Map.pop(:subject),
          {course_attrs, attrs} <- attrs |> Map.pop(:course),
          {semester_attrs, attrs} <- attrs |> Map.pop(:semester),
          {part_of_term_code, attrs} <- attrs |> Map.pop("part_of_term"),
          {status_code, attrs} <- attrs |> Map.pop("status"),
          course <- get_in(cache, [Course, course_code(subject_attrs[:code], course_attrs[:number])]),
          semester <- get_in(cache, [Semester, semester_attrs[:code]]),
          part_of_term <- get_in(cache, [:parts_of_term, part_of_term_code]),
          status <- get_in(cache, [:statuses, status_code])
        do
          Section.create_section(attrs, course, semester, part_of_term, status)
          |> repo_insert(repo, Section.conflict_keys())
          |> (&({&1.crn, &1})).()
        end
      end)
      |> Enum.into(%{})
      |> (&({:ok, &1})).()
    end
  end
end
