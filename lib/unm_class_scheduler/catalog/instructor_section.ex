defmodule UnmClassScheduler.Catalog.InstructorSection do
  @moduledoc """
  The join table between Instructors and Sections.

  This includes a `primary` attribute for if an instructor is the primary
  on a particular section.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Serializable

  alias UnmClassScheduler.Utils.ChangesetUtils
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

  @type serialized_t :: %{
    primary: boolean(),
    first: String.t(),
    middle_initial: String.t(),
    last: String.t(),
    email: String.t(),
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
      iex> InstructorSection.validate_data(
      ...>   %{primary: true},
      ...>   section: %Section{uuid: "SEC12345"},
      ...>   instructor: %Instructor{uuid: "INS12345"}
      ...> )
      {:ok, %{primary: true, section_uuid: "SEC12345", instructor_uuid: "INS12345"}}
  """
  @impl true
  @spec validate_data(valid_params(), valid_associations()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, associations) do
    %{section: section, instructor: instructor} = Map.new(associations)

    types = %{
      primary: :boolean,
      section_uuid: :string,
      instructor_uuid: :string,
    }

    {%{}, types}
    |> cast(params, [:primary])
    |> validate_required([:primary])
    |> ChangesetUtils.apply_association_uuids(%{
      section_uuid: section,
      instructor_uuid: instructor,
    })
    |> ChangesetUtils.apply_if_valid()
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

  In this case, emails alone are not actually unique.
  Some instructors are listed as "No UNM email address"

      iex> InstructorSection.conflict_keys()
      [:section_uuid, :instructor_uuid]
  """
  @impl true
  @spec conflict_keys() :: list(atom())
  def conflict_keys(), do: [:section_uuid, :instructor_uuid]

  @doc """
  Transforms an InstructorSection into a normal map intended for display to a user.

  This has the effect of flattening the associated Instructor and discarding the Section.

  ## Examples
      iex> instructor = %Instructor{
      ...>   uuid: "IN12345",
      ...>   first: "Testy", middle_initial: "M", last: "McTesterson",
      ...>   email: "test@testmail.com",
      ...> }
      iex> InstructorSection.serialize(%InstructorSection{
      ...>   uuid: "INS12345",
      ...>   primary: false,
      ...>   instructor: instructor,
      ...>   section: %Section{uuid: "SEC12345", crn: "CRN50001"},
      ...> })
      %{primary: false, first: "Testy", middle_initial: "M", last: "McTesterson", email: "test@testmail.com"}
  """
  @impl true
  @spec serialize(t()) :: serialized_t()
  def serialize(nil), do: nil
  def serialize(instructor_section) do
    %{primary: instructor_section.primary}
    |> Map.merge(Instructor.serialize(instructor_section.instructor))
  end
end
