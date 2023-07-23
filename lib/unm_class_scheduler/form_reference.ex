defmodule UnmClassScheduler.FormReference do
  @moduledoc """
  Context for fetching values to populate forms.

  This module is responsible for building and executing queries that
  populate the various form dropdowns and other fields involved in the frontend.

  While this will mainly be used on the Search form, other forms that need data
  population of the same kind will also use this context.
  """

  alias UnmClassScheduler.Repo
  alias UnmClassScheduler.Catalog.Semester
  alias UnmClassScheduler.Catalog.Subject
  alias UnmClassScheduler.Catalog.Course
  alias UnmClassScheduler.Catalog.Campus

  import Ecto.Query

  @spec fetch_semesters() :: list(Semester.serialized_t())
  def fetch_semesters() do
    Semester
    |> order_by([:code])
    |> Repo.all()
    |> Enum.map(&Semester.serialize/1)
  end

  @spec fetch_campuses() :: list(Campus.serialized_t())
  def fetch_campuses() do
    Campus
    |> order_by([:code])
    |> Repo.all()
    |> Enum.map(&Campus.serialize/1)
  end

  @spec fetch_subjects() :: list(Subject.serialized_t())
  def fetch_subjects() do
    Subject
    |> order_by([:code])
    |> Repo.all()
    |> Enum.map(&Subject.serialize/1)
  end

  @doc """
  Gets a list of courses that are associated with the given subject code.
  """
  @spec fetch_courses(String.t()) :: list(Course.serialized_t())
  def fetch_courses(subject_code) do
    Course
    |> join(:left, [course], subject in assoc(course, :subject), as: :subject)
    |> where([course, subject: subject], subject.code == ^subject_code)
    # This ordering is a little finicky, since course number is a string.
    # But it's good enough for now.
    |> order_by([course], [course.number])
    |> Repo.all()
    |> Enum.map(&Course.serialize/1)
  end
end
