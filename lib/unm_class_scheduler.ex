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
  }

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

  def testinsert(state) do
    multi = Ecto.Multi.new()
    |> Ecto.Multi.run(:semesters, fn repo, _ ->
      semesters = Enum.map(state[:semesters], fn {_, attrs} ->
        %Semester{}
        |> Semester.changeset(attrs)
        |> repo.insert!(
          on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
          conflict_target: :code,
          returning: true
        )
      end) |> Enum.reduce(%{}, fn semester, acc ->
        Map.put(acc, semester.code, semester)
      end)
      {:ok, semesters}
    end)
    |> Ecto.Multi.run(:campuses, fn repo, _ ->
      campuses = Enum.map(state[:campuses], fn {_, attrs} ->
        %Campus{}
        |> Campus.changeset(attrs)
        |> repo.insert!(
          on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
          conflict_target: :code,
          returning: true
        )
      end)
      {:ok, campuses}
    end)
    |> Ecto.Multi.run(:colleges, fn repo, _ ->
      colleges = Enum.map(state[:colleges], fn {_, attrs} ->
        %College{}
        |> College.changeset(attrs)
        |> repo.insert!(
          on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
          conflict_target: :code,
          returning: true
        )
      end)
      {:ok, colleges}
    end)
    |> Ecto.Multi.run(:departments, fn repo, _ ->
      departments = Enum.map(state[:departments], fn {_, attrs} ->
        {college_attrs, attrs} = attrs |> Map.pop(:college)
        college = repo.get_by!(College, college_attrs)
        Ecto.build_assoc(college, :departments)
        |> Department.changeset(attrs)
        |> repo.insert!(
          on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
          conflict_target: :code,
          returning: true
        )
      end) |> Enum.reduce(%{}, fn department, acc ->
        Map.put(acc, department.code, department)
      end)
      {:ok, departments}
    end)
    |> Ecto.Multi.run(:subjects, fn repo, updated ->
      subjects = Enum.map(state[:subjects], fn {_, attrs} ->
        {department_attrs, attrs} = attrs |> Map.pop(:department)

        updated
        |> get_in([:departments, department_attrs[:code]])
        |> Ecto.build_assoc(:subjects)
        |> Subject.changeset(attrs)
        |> repo.insert!(
          on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
          conflict_target: :code,
          returning: true
        )
      end) |> Enum.reduce(%{}, fn subject, acc ->
        Map.put(acc, subject.code, subject)
      end)
      {:ok, subjects}
    end)
    |> Ecto.Multi.run(:courses, fn repo, updated ->
      courses = Enum.map(state[:courses], fn {_, attrs} ->
        {subject_attrs, attrs} = attrs |> Map.pop(:subject)

        updated
        |> get_in([:subjects, subject_attrs[:code]])
        |> Ecto.build_assoc(:courses)
        |> Course.changeset(attrs)
        |> repo.insert!(
          on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
          conflict_target: [:subject_uuid, :number],
          returning: true
        ) |> (&({subject_attrs[:code], &1})).()
      end) |> Enum.reduce(%{}, fn {subject_code, course}, acc ->
        Map.put(acc, "#{subject_code}__#{course.number}", course)
      end)
      {:ok, courses}
    end)
    # FIXME: Not entirely sure how best to make this part work, since it has multiple parent associations,
    # and one of them doesn't even have a unique code I can look for.
    |> Ecto.Multi.run(:sections, fn repo, updated ->
      sections = Enum.map(state[:sections], fn {_, attrs} ->
        # There has to be a cleaner way to achieve this...
        {subject_attrs, attrs} = attrs |> Map.pop(:subject)
        {course_attrs, attrs} = attrs |> Map.pop(:course)
        {semester_attrs, attrs} = attrs |> Map.pop(:semester)

        course = get_in(updated, [:courses, "#{subject_attrs[:code]}__#{course_attrs[:number]}"])
        semester = get_in(updated, [:semesters, semester_attrs[:code]])

        Section.create_section(attrs, course, semester)
        |> repo.insert!(
          on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
          conflict_target: [:crn, :semester_uuid],
          returning: true
        )
      end)
      {:ok, sections}
    end)

    UnmClassScheduler.Repo.transaction(multi)
  end
end
