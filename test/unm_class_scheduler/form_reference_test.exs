defmodule UnmClassScheduler.FormReferenceTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use UnmClassScheduler.DataCase

  alias UnmClassScheduler.FormReference

  doctest UnmClassScheduler.FormReference

  test "fetch_semesters/0 returns all semesters" do
    semesters = FormReference.fetch_semesters()
    |> Enum.sort()

    assert semesters == [
      %{code: "202310", name: "Spring 2023"},
      %{code: "202360", name: "Summer 2023"},
    ]
  end

  test "fetch_campuses/0 returns all campuses" do
    campuses = FormReference.fetch_campuses()
    |> Enum.sort()

    assert campuses == [
      %{code: "ABQ", name: "Albuquerque/Main"},
      %{code: "GA", name: "Gallup"},
      %{code: "LA", name: "Los Alamos"},
    ]
  end

  test "fetch_subjects/0 returns all subjects" do
    subjects = FormReference.fetch_subjects()
    |> Enum.sort()

    assert subjects == [
      %{code: "SUBJ1", name: "Subject 1"},
      %{code: "SUBJ2", name: "Subject 2"},
    ]
  end

  describe "fetch_courses/1" do
    test "when a valid subject is given" do
      courses = FormReference.fetch_courses("SUBJ1")
      |> Enum.sort()

      assert courses == [
        %{catalog_description: "SUBJ1 111 description", number: "111", title: "Course 1.1"},
        %{catalog_description: "SUBJ1 112 description", number: "112", title: "Course 1.2"},
      ]
    end

    test "when an invalid subject is given" do
      courses = FormReference.fetch_courses("NOPE")
      |> Enum.sort()

      assert courses == []
    end
  end
end
