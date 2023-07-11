defmodule UnmClassScheduler.Catalog.InstructorSection do
  @moduledoc """
  The join table between Instructors and Sections.

  This includes a `primary` attribute for if an instructor is the primary
  on a particular section.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils
  alias UnmClassScheduler.Catalog.Section
  alias UnmClassScheduler.Catalog.Instructor

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    uuid: String.t(),
    primary: boolean(),
    section: Section.t(),
    section_uuid: String.t(),
    instructor: Instructor.t(),
    instructor_uuid: String.t(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @type valid_params :: %{
    primary: boolean()
  }

  @type valid_associations :: [
    {:section, Section.t()},
    {:instructor, Instructor.t()}
  ]

  schema "instructors_sections" do
    field :primary, :boolean, default: false
    belongs_to :section, Section, references: :uuid, foreign_key: :section_uuid
    belongs_to :instructor, Instructor, references: :uuid, foreign_key: :instructor_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  ## Examples
      iex> UnmClassScheduler.Catalog.Instructor.validate_data(
      ...>   %{primary: true},
      ...>   section: %UnmClassScheduler.Catalog.Section{uuid: "SEC12345"},
      ...>   instructor: %UnmClassScheduler.Catalog.Instructor{uuid: "INS12345"}
      ...> )
      {:ok, %{primary: true, section_uuid: "SEC12345", instructor_uuid: "INS12345"}}
  """
  @spec validate_data(valid_params(), valid_associations()) :: SchemaUtils.maybe_valid_changes()
  @impl true
  def validate_data(params, section: section, instructor: instructor) do
    types = %{
      primary: :boolean,
      section_uuid: :string,
      instructor_uuid: :string,
    }

    {%{}, types}
    |> cast(params, [:primary])
    |> SchemaUtils.apply_association_uuids(%{
      section_uuid: section,
      instructor_uuid: instructor,
    })
    |> SchemaUtils.apply_changeset_if_valid()
  end

  @impl true
  def conflict_keys(), do: [:section_uuid, :instructor_uuid]
end
