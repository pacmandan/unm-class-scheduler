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
      end)
      {:ok, departments}
    end)
    |> Ecto.Multi.run(:subjects, fn repo, _ ->
      subjects = Enum.map(state[:subjects], fn {_, attrs} ->
        {department_attrs, attrs} = attrs |> Map.pop(:department)
        department = repo.get_by!(Department, department_attrs)
        Ecto.build_assoc(department, :subjects)
        |> Subject.changeset(attrs)
        |> repo.insert!(
          on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
          conflict_target: :code,
          returning: true
        )
      end)
      {:ok, subjects}
    end)
    |> Ecto.Multi.run(:courses, fn repo, _ ->
      courses = Enum.map(state[:courses], fn {_, attrs} ->
        {subject_attrs, attrs} = attrs |> Map.pop(:subject)
        subject = repo.get_by!(Subject, subject_attrs)
        Ecto.build_assoc(subject, :courses)
        |> Course.changeset(attrs)
        |> repo.insert!(
          on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
          conflict_target: [:subject_uuid, :number],
          returning: true
        )
      end)
      {:ok, courses}
    end)
    # FIXME: Not entirely sure how best to make this part work, since it has multiple parent associations,
    # and one of them doesn't even have a unique code I can look for.
    |> Ecto.Multi.run(:sections, fn _repo, _ ->
      sections = Enum.map(state[:sections], fn {_, _attrs} ->
        true #<-- Added to make the warning go away for now.

        # There has to be a cleaner way to achieve this...
        # {subject_attrs, attrs} = attrs |> Map.pop(:subject)
        # {course_attrs, attrs} = attrs |> Map.pop(:course)
        # {semester_attrs, attrs} = attrs |> Map.pop(:semester)


        # #Ecto.Query.where()

        # Surely I can do this in two calls?
        # semester = repo.get_by!(Semester, semester_attrs)
        # subject = repo.get_by!(Subject, subject_attrs)
        # course = repo.get_by!(Course, )

        # Should part of this association building be in the model?
        # Ecto.build_assoc(course, :sections)
        # |> Ecto.Changeset.put_assoc(:semester, semester)
        # Since validation is run on changeset(), need to add associations first?
        # Maybe figure out another way to do this?
        # |> Section.changeset(attrs)
        # |> repo.insert!(
        #   on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
        #   conflict_target: [:crn, :semester_uuid],
        #   returning: true
        # )
      end)
      {:ok, sections}
    end)

    UnmClassScheduler.Repo.transaction(multi)
  end
end
