defmodule UnmClassScheduler.Catalog.Course do
  alias UnmClassScheduler.Catalog.{
    Subject,
    Section
  }

  use UnmClassScheduler.Schema, conflict_keys: [:number, :subject_uuid]
  use UnmClassScheduler.Schema.Parent, child: :sections
  use UnmClassScheduler.Schema.Child, parent: Subject

  import Ecto.Changeset

  schema "courses" do
    field :number, :string
    field :title, :string
    field :catalog_description, :string

    belongs_to :subject, Subject, references: :uuid, foreign_key: :subject_uuid
    has_many :sections, Section, references: :uuid, foreign_key: :course_uuid

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:number, :title, :catalog_description])
    |> validate_required([:number, :title, :subject_uuid])
    |> unique_constraint([:number, :subject_uuid])
  end

  def validate(params, subject) do
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

  def parent_key(), do: :subject

  def parent(course), do: course.subject

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
