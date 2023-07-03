defmodule UnmClassScheduler.Catalog.Course do
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.HasParent

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Catalog.Subject
  alias UnmClassScheduler.Catalog.Section

  schema "courses" do
    field :number, :string
    field :title, :string
    field :catalog_description, :string

    belongs_to :subject, Subject, references: :uuid, foreign_key: :subject_uuid
    has_many :sections, Section, references: :uuid, foreign_key: :course_uuid

    timestamps()
  end

  @impl true
  def validate_data(params, subject: subject) do
    data = %{}
    types = %{number: :string, title: :string, catalog_description: :string, subject_uuid: :string}
    cs = {data, types}
    |> cast(params |> Map.merge(%{subject_uuid: subject.uuid}), [:number, :title, :catalog_description, :subject_uuid])
    |> validate_required([:number, :title])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end

  @impl true
  def parent_module(), do: Subject

  @impl true
  def parent_key(), do: :subject

  @impl true
  def get_parent(course), do: course.subject

  @impl true
  def conflict_keys(), do: [:number, :subject_uuid]

  # Proposed view for finding courses by number and subject.
  # I'll wait to implement this until we start getting into the search API.
  # It might not be necessary and/or worsen performance, I don't know yet.
  # execute """
  #   CREATE VIEW course_subjects AS
  #     SELECT subjects.code AS subject_code,
  #            departments.code AS department_code,
  #            colleges.code AS college_code,
  #            number,
  #            title,
  #            catalog_description,
  #            courses.uuid AS uuid
  #     FROM courses
  #       INNER JOIN subjects ON (courses.subject_uuid = subjects.uuid)
  #       INNER JOIN departments ON (subjects.department_uuid = departments.uuid)
  #       INNER JOIN colleges ON (departments.college_uuid = colleges.uuid);
  #   """
end
