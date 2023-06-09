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
        IO.inspect(attrs)
        {college_attrs, attrs} = attrs |> Map.pop(:college)
        IO.inspect(college_attrs)
        IO.inspect(attrs)
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

    UnmClassScheduler.Repo.transaction(multi)
  end
end
