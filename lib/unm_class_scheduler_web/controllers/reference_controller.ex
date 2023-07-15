defmodule UnmClassSchedulerWeb.ReferenceController do
  use UnmClassSchedulerWeb, :controller

  alias UnmClassScheduler.Api.Reference

  def get_semesters(conn, _params) do
    semesters = Reference.get_semesters()
    json(conn, semesters)
  end

  def get_campuses(conn, _params) do
    campuses = Reference.get_campuses()
    json(conn, campuses)
  end

  def get_subjects(conn, _params) do
    subjects = Reference.get_subjects()
    json(conn, subjects)
  end

  def get_courses(conn, %{"subject" => subject_code}) do
    courses = Reference.get_courses_by_subject(subject_code)
    json(conn, courses)
  end
end
