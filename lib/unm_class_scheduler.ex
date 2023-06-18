defmodule UnmClassScheduler do
  @moduledoc """
  UnmClassScheduler keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

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

  # FIXME: This is just me sandboxing solutions. I do not intend to keep ANY of this code in this module.

  def testload do
    stream = File.stream!(Path.expand("./xmls/current.xml"))
    {:ok, state} = Saxy.parse_stream(stream, UnmClassScheduler.ScheduleParser.EventHandler, %{})
    testinsert(state)
  end

  def teststate do
    %{
      semesters: %{
        "202310" => %{code: "202310", name: "Spring 2023"},
      },
      campuses: %{
        "ABQ" => %{code: "ABQ", name: "Albuquerque/Main"},
        "GA" => %{code: "GA", name: "Gallup"},
        "LA" => %{code: "LA", name: "Los Alamos"},
      },
      colleges: %{
        "AP" => %{code: "AP", name: "Schole of Arch. and Planning"},
        "AS" => %{code: "AS", name: "College of Arts and Sciences"},
        "EH" => %{code: "EH", name: "College of Educ & Human Sci"},
        "EN" => %{code: "EN", name: "School of Engineering"},
      }
    }
  end

  def repo_insert(changeset, repo, conflict_target) do
    repo.insert!(
      changeset,
      on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
      conflict_target: conflict_target,
      returning: true
    )
  end

  def cache_inserted(inserted, keyfn) do
    cache_inserted(inserted, keyfn, &no_op/1)
  end

  def cache_inserted(inserted, keyfn, valuefn) do
    Enum.reduce(inserted, %{}, fn value, acc ->
      Map.put(acc, keyfn.(value), valuefn.(value))
    end)
  end

  def no_op(value) do
    value
  end

  def get_code(changeset) do
    changeset.code
  end

  def course_code(course) when not is_nil(course.subject) do
    course_code(course, course.subject)
  end

  def course_code(course, subject) when is_struct(course) and is_struct(subject) do
    course_code(course.number, subject.code)
  end

  def course_code(course_number, subject_code) when is_binary(course_number) and is_binary(subject_code) do
    "#{subject_code}__#{course_number}"
  end

  def testinsert(state) do
    # TODO: Figure out how to cache these ahead of time to avoid repeated read queries
    # parts_of_term = UnmClassScheduler.Repo.all(from(PartOfTerm, []))
    # |> Enum.reduce(%{}, fn pot, acc -> Map.put(acc, pot[:code], pot) end)

    # statuses = UnmClassScheduler.Repo.all(from(Status, []))
    # |> Enum.reduce(%{}, fn status, acc -> Map.put(acc, status[:code], status) end)

    multi = Ecto.Multi.new()
    |> Ecto.Multi.run(:semesters, fn repo, _ ->
      semesters = Enum.map(state[:semesters], fn {_, attrs} ->
        %Semester{}
        |> Semester.changeset(attrs)
        |> repo_insert(repo, :code)
      end) |> cache_inserted(&get_code/1)
      {:ok, semesters}
    end)
    |> Ecto.Multi.run(:campuses, fn repo, _ ->
      campuses = Enum.map(state[:campuses], fn {_, attrs} ->
        %Campus{}
        |> Campus.changeset(attrs)
        |> repo_insert(repo, :code)
      end)
      {:ok, campuses}
    end)
    |> Ecto.Multi.run(:colleges, fn repo, _ ->
      colleges = Enum.map(state[:colleges], fn {_, attrs} ->
        %College{}
        |> College.changeset(attrs)
        |> repo_insert(repo, :code)
      end) |> cache_inserted(&get_code/1)
      {:ok, colleges}
    end)
    |> Ecto.Multi.run(:departments, fn repo, updated ->
      departments = Enum.map(state[:departments], fn {_, attrs} ->
        {college_attrs, attrs} = attrs |> Map.pop(:college)

        updated
        |> get_in([:colleges, college_attrs[:code]])
        |> Ecto.build_assoc(:departments)
        |> Department.changeset(attrs)
        |> repo_insert(repo, :code)
      end) |> cache_inserted(&get_code/1)
      {:ok, departments}
    end)
    |> Ecto.Multi.run(:subjects, fn repo, updated ->
      subjects = Enum.map(state[:subjects], fn {_, attrs} ->
        {department_attrs, attrs} = attrs |> Map.pop(:department)

        updated
        |> get_in([:departments, department_attrs[:code]])
        |> Ecto.build_assoc(:subjects)
        |> Subject.changeset(attrs)
        |> repo_insert(repo, :code)
      end) |> cache_inserted(&get_code/1)
      {:ok, subjects}
    end)
    |> Ecto.Multi.run(:courses, fn repo, updated ->
      courses = Enum.map(state[:courses], fn {_, attrs} ->

        with {subject_attrs, attrs} <- attrs |> Map.pop(:subject),
              subject <- get_in(updated, [:subjects, subject_attrs[:code]])
        do
          subject
          |> Ecto.build_assoc(:courses)
          |> Course.changeset(attrs)
          |> repo_insert(repo, [:subject_uuid, :number])
          |> (&({&1, subject})).()
        end

      end) |> cache_inserted((fn {course, subj} -> course_code(course, subj) end), &(elem(&1, 0)))
      {:ok, courses}
    end)
    |> Ecto.Multi.run(:sections, fn repo, updated ->
      sections = Enum.map(state[:sections], fn {_, attrs} ->
        with {subject_attrs, attrs} <- attrs |> Map.pop(:subject),
             {course_attrs, attrs} <- attrs |> Map.pop(:course),
             {semester_attrs, attrs} <- attrs |> Map.pop(:semester),
             {part_of_term_code, attrs} <- attrs |> Map.pop("part_of_term"),
             {status_code, attrs} <- attrs |> Map.pop("status"),
             course <- get_in(updated, [:courses, course_code(course_attrs[:number], subject_attrs[:code])]),
             semester <- get_in(updated, [:semesters, semester_attrs[:code]]),
             # part_of_term <- Map.get(parts_of_term, part_of_term_code),
             part_of_term <- repo.get_by(PartOfTerm, code: part_of_term_code),
             # status <- Map.get(statuses, status_code)
             status <- repo.get_by(Status, code: status_code)
        do
          Section.create_section(attrs, course, semester, part_of_term, status)
          |> repo_insert(repo, [:crn, :semester_uuid])
        end
      end) |> cache_inserted(&(&1.crn))
      {:ok, sections}
    end)

    UnmClassScheduler.Repo.transaction(multi, timeout: 60_000)
  end
end
