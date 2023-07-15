defmodule UnmClassScheduler.Api.Reference do
  alias UnmClassScheduler.Repo
  alias UnmClassScheduler.Catalog.Semester
  alias UnmClassScheduler.Catalog.Subject
  alias UnmClassScheduler.Catalog.Course
  alias UnmClassScheduler.Catalog.Campus

  import Ecto.Query

  def get_semesters() do
    Semester
    |> order_by([:code])
    |> Repo.all()
    |> Enum.map(&Semester.serialize/1)
  end

  def get_campuses() do
    Campus
    |> order_by([:code])
    |> Repo.all()
    |> Enum.map(&Campus.serialize/1)
  end

  def get_subjects() do
    Subject
    |> order_by([:code])
    |> Repo.all()
    |> Enum.map(&Subject.serialize/1)
  end

  def get_courses_by_subject(subject_code) do
    Course
    |> join(:left, [course], subject in assoc(course, :subject), as: :subject)
    |> where([course, subject: subject], subject.code == ^subject_code)
    |> order_by([course], [course.number])
    |> Repo.all()
    |> Enum.map(&Course.serialize/1)
    |> Enum.map(fn course -> course.number end)
  end
end
