defmodule UnmClassScheduler.Catalog.Instructor do
  @moduledoc """
  Data representing an instructor at UNM.

  In theory they have a unique email. However, some instructors are listed
  as "No UNM email address". So they are instead unique by name and email.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils
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

  @type valid_params :: %{
    first: String.t(),
    middle_initial: String.t(),
    last: String.t(),
    email: String.t(),
  }

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
      iex> UnmClassScheduler.Catalog.Instructor.validate_data(%{
      ...>   first: "Testy", middle_initial: "M", last: "McTesterson",
      ...>   email: "test@testmail.com",
      ...> })
      {:ok, %{first: "Testy", middle_initial: "M", last: "McTesterson", email: "test@testmail.com"}}

      iex> UnmClassScheduler.Catalog.Instructor.validate_data(%{
      ...>   first: "Testy", middle_initial: "M", last: "McTesterson"
      ...> })
      {:error, [email: {"can't be blank", [validation: :required]}]}
  """
  @spec validate_data(valid_params(), term()) :: SchemaUtils.maybe_valid_changes()
  @impl true
  def validate_data(params, _associations \\ []) do
    types = %{first: :string, last: :string, middle_initial: :string, email: :string}
    {%{}, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:first, :last, :email])
    |> SchemaUtils.apply_changeset_if_valid()
  end

  # Emails are not unique - some instructors are listed as "No UNM email address"
  @impl true
  def conflict_keys(), do: [:email, :first, :last]
end
