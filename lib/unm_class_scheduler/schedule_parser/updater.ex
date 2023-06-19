defmodule UnmClassScheduler.ScheduleParser.Updater do
  alias UnmClassScheduler.Repo
  alias UnmClassScheduler.ScheduleParser.EventHandler
  alias UnmClassScheduler.Catalog.{
    Semester,
    Campus,
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

  @type multi_state :: %{
    optional(atom()) => schema_cache()
  }

  @type schema_cache :: %{
    optional(binary()) => struct()
  }

  def mass_insert(schemas) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(
      :part_of_term,
      fetch_coded_and_cache_all(PartOfTerm)
    )
    |> Ecto.Multi.run(
      :status,
      fetch_coded_and_cache_all(Status)
    )
    |> Ecto.Multi.run(
      :semester,
      insert_coded_schema(schemas[:semesters], Semester)
    )
    |> Ecto.Multi.run(
      :campus,
      insert_coded_schema(schemas[:campuses], Campus)
    )
    |> Ecto.Multi.run(
      :college,
      insert_coded_schema(schemas[:colleges], College)
    )
    |> Ecto.Multi.run(
      :department,
      insert_linked_coded_schema(schemas[:departments], Department, :departments, :college)
    )
    |> Ecto.Multi.run(
      :subject,
      insert_linked_coded_schema(schemas[:subjects], Subject, :subjects, :department)
    )
    |> Ecto.Multi.run(
      :course,
      insert_courses(schemas[:courses])
    )
    |> Ecto.Multi.run(
      :section,
      insert_section(schemas[:sections])
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

  # Semester, Campus, College
  defp insert_coded_schema(attrs_to_insert, schema) do
    fn repo, _cache ->
      Enum.map(attrs_to_insert, fn {_, attrs} ->
        struct(schema)
        |> schema.changeset(attrs)
        |> repo_insert(repo, :code)
        |> (&({&1.code, &1})).()
      end)
      |> Enum.into(%{})
      |> (&({:ok, &1})).()
    end
  end

  # Department, Subject
  defp insert_linked_coded_schema(attrs_to_insert, schema, child_key, parent_attrs_key) do
    fn repo, cache ->
      Enum.map(attrs_to_insert, fn {_, attrs} ->
        with {parent_attrs, attrs} <- attrs |> Map.pop(parent_attrs_key),
          parent <- get_in(cache, [parent_attrs_key, parent_attrs[:code]])
        do
          Ecto.build_assoc(parent, child_key)
          |> schema.changeset(attrs)
          |> repo_insert(repo, :code)
          |> (&({&1.code, &1})).()
        end
      end)
      |> Enum.into(%{})
      |> (&({:ok, &1})).()
    end
  end

  # Course
  defp insert_courses(attrs_to_insert) do
    fn repo, cache ->
      Enum.map(attrs_to_insert, fn {_, attrs} ->
        with {subject_attrs, attrs} <- attrs |> Map.pop(:subject),
          subject <- get_in(cache, [:subject, subject_attrs[:code]])
        do
          Ecto.build_assoc(subject, :courses)
          |> Course.changeset(attrs)
          |> repo_insert(repo, [:subject_uuid, :number])
          |> (&({"#{subject.code}__#{&1.number}", &1})).()
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
          course <- get_in(cache, [:course, "#{subject_attrs[:code]}__#{course_attrs[:number]}"]),
          semester <- get_in(cache, [:semester, semester_attrs[:code]]),
          part_of_term <- get_in(cache, [:part_of_term, part_of_term_code]),
          # part_of_term <- repo.get_by(PartOfTerm, code: part_of_term_code),
          status <- get_in(cache, [:status, status_code])
          # status <- repo.get_by(Status, code: status_code)
        do
          Section.create_section(attrs, course, semester, part_of_term, status)
          |> repo_insert(repo, [:crn, :semester_uuid])
          |> (&({&1.crn, &1})).()
        end
      end)
      |> Enum.into(%{})
      |> (&({:ok, &1})).()
    end
  end
end
