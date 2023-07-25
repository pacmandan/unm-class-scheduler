defmodule UnmClassScheduler.Catalog.Course do
  @moduledoc """
  Data representing a Course at UNM.

  Each course is uniquely identified by its subject and number.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.HasParent
  @behaviour UnmClassScheduler.Schema.Serializable

  alias UnmClassScheduler.Utils.ChangesetUtils
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

  @typedoc """
  The map structure intended for display to a user.
  Omits UUIDs, timestamps, and associations.
  """
  @type serialized_t :: %{
    number: String.t(),
    title: String.t(),
    catalog_description: String.t(),
  }

  @type valid_params :: serialized_t()

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
      iex> Course.validate_data(
      ...>   %{number: "123L", title: "Test Course", catalog_description: "This is a test course."},
      ...>   subject: %Subject{uuid: "SUBJ12345"}
      ...> )
      {:ok,  %{number: "123L", title: "Test Course", catalog_description: "This is a test course.", subject_uuid: "SUBJ12345"}}

      iex> Course.validate_data(
      ...>   %{number: "123L", title: "Test Course"},
      ...>   subject: %Subject{}
      ...> )
      {:error, [subject_uuid: {"can't be blank", [validation: :required]}]}
  """
  @impl true
  @spec validate_data(valid_params(), valid_associations()) :: ChangesetUtils.maybe_valid_changes()
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
    |> ChangesetUtils.apply_association_uuids(%{subject_uuid: subject})
    |> ChangesetUtils.apply_if_valid()
  end

  @doc """
  Gets the parent association module for this record.
  In this case, `UnmClassScheduler.Catalog.Subject`.
  This is used primarily in the updater context.

  Examples:
      iex> Course.parent_module()
      UnmClassScheduler.Catalog.Subject
  """
  @impl true
  @spec parent_module :: module()
  def parent_module(), do: Subject

  @doc """
  Gets the key associated with the parent record in this record.
  This is used primarily in the updater context.

  Examples:
      iex> Course.parent_key()
      :subject
  """
  @impl true
  @spec parent_key :: atom()
  def parent_key(), do: :subject

  @doc """
  Gets the parent association of this record. In this case, the parent Subject.

  ## Examples
      iex> s = %Subject{uuid: "12345"}
      iex> c = %Course{uuid: "67890", subject: s}
      iex> Course.get_parent(c)
      %Subject{uuid: "12345"}

      iex> Course.get_parent(%Course{uuid: "67890"})
      nil
  """
  @impl true
  @spec get_parent(t()) :: Subject.t()
  def get_parent(course) do
    if Ecto.assoc_loaded?(course.subject) do
      course.subject
    else
      nil
    end
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> Course.conflict_keys()
      [:number, :subject_uuid]
  """
  @impl true
  @spec conflict_keys :: list(atom())
  def conflict_keys(), do: [:number, :subject_uuid]

  @doc """
  Transforms a Course into a normal map intended for display to a user.

  ## Examples
      iex> Course.serialize(%Course{uuid: "123456", number: "123L", title: "Test Course", catalog_description: "This is a test course."})
      %{number: "123L", title: "Test Course", catalog_description: "This is a test course."}
  """
  @impl true
  @spec serialize(t()) :: serialized_t()
  def serialize(nil), do: nil
  def serialize(course) do
    %{
      number: course.number,
      title: course.title,
      catalog_description: course.catalog_description,
    }
  end

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
