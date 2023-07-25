defmodule UnmClassScheduler.Catalog.Instructor do
  @moduledoc """
  Data representing an instructor at UNM.

  In theory they have a unique email. However, some instructors are listed
  as "No UNM email address". So they are instead unique by name and email.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Serializable

  alias UnmClassScheduler.Utils.ChangesetUtils
  alias UnmClassScheduler.Catalog.InstructorSection

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    uuid: String.t(),
    first: String.t(),
    last: String.t(),
    middle_initial: String.t(),
    email: String.t(),
    sections: list(InstructorSection.t()),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @typedoc """
  The map structure intended for display to a user.
  Omits UUIDs, timestamps, and associations.
  """
  @type serialized_t :: %{
    first: String.t(),
    middle_initial: String.t(),
    last: String.t(),
    email: String.t(),
  }

  @type valid_params :: serialized_t()

  schema "instructors" do
    field :first, :string
    field :last, :string
    field :middle_initial, :string
    field :email, :string

    # Can't do many_to_many - it would skip the "primary" field on the join table.
    #many_to_many :sections, Section, join_through: InstructorSection, join_keys: [instructor_uuid: :uuid, section_uuid: :uuid]
    has_many :sections, InstructorSection, references: :uuid, foreign_key: :instructor_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  Associations with Instructors are many-to-many, and are therefore not added
  via this mechanism. Any associations passed to this are ignored.

  `first`, `last`, and `email` are all required.

  ## Examples
      iex> Instructor.validate_data(%{
      ...>   first: "Testy", middle_initial: "M", last: "McTesterson",
      ...>   email: "test@testmail.com",
      ...> })
      {:ok, %{first: "Testy", middle_initial: "M", last: "McTesterson", email: "test@testmail.com"}}

      iex> Instructor.validate_data(%{
      ...>   first: "Testy", middle_initial: "M", last: "McTesterson"
      ...> })
      {:error, [email: {"can't be blank", [validation: :required]}]}
  """
  @impl true
  @spec validate_data(valid_params(), term()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, _associations \\ []) do
    types = %{first: :string, last: :string, middle_initial: :string, email: :string}
    {%{}, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:first, :last, :email])
    |> ChangesetUtils.apply_if_valid()
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

  In this case, emails alone are not actually unique.
  Some instructors are listed as "No UNM email address"

      iex> Instructor.conflict_keys()
      [:email, :first, :last]
  """
  @impl true
  @spec conflict_keys() :: list(atom())
  def conflict_keys(), do: [:email, :first, :last]

  @doc """
  Transforms an Instructor into a normal map intended for display to a user.

  ## Examples
      iex> Instructor.serialize(%Instructor{
      ...>   uuid: "IN12345",
      ...>   first: "Testy", middle_initial: "M", last: "McTesterson",
      ...>   email: "test@testmail.com",
      ...> })
      %{first: "Testy", middle_initial: "M", last: "McTesterson", email: "test@testmail.com"}
  """
  @impl true
  @spec serialize(t()) :: serialized_t()
  def serialize(nil), do: nil
  def serialize(instructor) do
    %{
      first: instructor.first,
      last: instructor.last,
      middle_initial: instructor.middle_initial,
      email: instructor.email,
    }
  end
end
