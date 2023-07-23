defmodule UnmClassSchedulerWeb.ReferenceController do
  use UnmClassSchedulerWeb, :controller

  alias UnmClassScheduler.FormReference

  def get_semesters(conn, _params) do
    semesters = FormReference.fetch_semesters()
    json(conn, semesters)
  end

  def get_campuses(conn, _params) do
    campuses = FormReference.fetch_campuses()
    json(conn, campuses)
  end

  def get_subjects(conn, _params) do
    subjects = FormReference.fetch_subjects()
    json(conn, subjects)
  end

  def get_courses(conn, %{"subject" => subject_code}) do
    # TODO: Validate params using Changeset.
    # Set up multiple Request.prepare() functions in subcontexts.
    # (Or in one module, just multiple functions.)
    # It seems really silly, but it'd give more control over
    # the error response.
    courses = FormReference.fetch_courses(subject_code)
    json(conn, courses)
  end
end
