defmodule UnmClassScheduler.Catalog.Course do
  @moduledoc """
  Data representing a Course at UNM.

  Each course is uniquely identified by its subject and number.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.HasParent
  @behaviour UnmClassScheduler.Schema.Serializable

  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils
  alias UnmClassScheduler.Catalog.Subject
  alias UnmClassScheduler.Catalog.Section

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    uuid: String.t(),
    number: String.t(),
    title: String.t(),
    catalog_description: String.t(),
    subject: Subject.t(),
    subject_uuid: String.t(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @type serialized_t :: %{
    number: String.t(),
    title: String.t(),
    catalog_description: String.t(),
  }

  @type valid_params :: %{
    code: String.t(),
    name: String.t(),
  }

  @type valid_associations :: [
    {:subject, Subject.t()}
  ]

  schema "courses" do
    field :number, :string
    field :title, :string
    field :catalog_description, :string

    belongs_to :subject, Subject, references: :uuid, foreign_key: :subject_uuid
    has_many :sections, Section, references: :uuid, foreign_key: :course_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  Courses have a parent Subject association. The uuid ffrom this association
  gets applied to the input params as `:subject_uuid`.

  ## Examples
      iex> UnmClassScheduler.Catalog.Course.validate_data(
      ...>   %{number: "123L", title: "Test Course", catalog_description: "This is a test course."},
      ...>   subject: %UnmClassScheduler.Catalog.Subject{uuid: "SUBJ12345"}
      ...> )
      {:ok,  %{number: "123L", title: "Test Course", catalog_description: "This is a test course.", subject_uuid: "SUBJ12345"}}

      iex> UnmClassScheduler.Catalog.Course.validate_data(
      ...>   %{number: "123L", title: "Test Course"},
      ...>   subject: %UnmClassScheduler.Catalog.Subject{}
      ...> )
      {:error, [subject_uuid: {"can't be blank", [validation: :required]}]}
  """
  @spec validate_data(valid_params(), valid_associations()) :: SchemaUtils.maybe_valid_changes()
  @impl true
  def validate_data(params, subject: subject) do
    types = %{
      number: :string,
      title: :string,
      catalog_description: :string,
      subject_uuid: :string
    }

    {%{}, types}
    |> cast(params, [:number, :title, :catalog_description])
    |> validate_required([:number, :title])
    |> SchemaUtils.apply_association_uuids(%{subject_uuid: subject})
    |> SchemaUtils.apply_changeset_if_valid()
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

  @spec serialize(__MODULE__.t()) :: __MODULE__.serialized_t()
  @impl true
  def serialize(nil), do: nil
  def serialize(course) do
    %{
      number: course.number,
      title: course.title,
      catalog_description: course.catalog_description,
    }
  end
end
