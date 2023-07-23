defmodule UnmClassScheduler.Catalog.Crosslist do
  @moduledoc """
  Data representing a section crosslist.

  Some Sections are "crosslisted" as other sections. Meaning that sometimes
  the same section is listed twice under different numbers. This crosslist
  keeps track of these multiple listings.

  `section` is the section listed, and `crosslist` is the _other_ section
  that this section is crosslisted as.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  alias UnmClassScheduler.Utils.ChangesetUtils
  alias UnmClassScheduler.Catalog.Section

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    uuid: String.t(),
    section: Section.t(),
    section_uuid: String.t(),
    crosslist: Section.t(),
    crosslist_uuid: String.t(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @type valid_params :: %{
    course_number: String.t(),
    subject_code: String.t(),
  }

  @type valid_associations :: [
    {:section, Section.t()},
    {:crosslist, maybe_section()},
  ]

  @typep maybe_section :: Section.t() | nil

  schema "crosslists" do
    belongs_to :section, Section, references: :uuid, foreign_key: :section_uuid
    belongs_to :crosslist, Section, references: :uuid, foreign_key: :crosslist_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  Only the `section` and `crosslist` associations are used for the returned data.
  It is also expected that the `section` and `crosslist` parameters have had their
  `course` and `course.subject` associations preloaded before being used here.

  The expected `params` to give are `%{course_number: c, subject_code: s}`.
  While these parameters are not used in the actual data (yet, I might add it in the future),
  they are used in validating if the `crosslist` is the correct crosslist.

  There are some crosslists in the original data that are just...incorrect.
  Crosslists in the original data show both the section number crosslist, as well
  as the relevant course number and subject code. Sometimes these simply don't line up.

  In that case, even if the given crosslist has a UUID, this validation may still throw an error
  if course number and subject code given in params don't match it.

  ## Examples
      iex> UnmClassScheduler.Catalog.Crosslist.validate_data(
      ...>   %{course_number: "123L", subject_code: "SUBJ"},
      ...>   section: %UnmClassScheduler.Catalog.Section{uuid: "SEC12345"},
      ...>   crosslist: %UnmClassScheduler.Catalog.Section{
      ...>     uuid: "SEC67890",
      ...>     course: %UnmClassScheduler.Catalog.Course{
      ...>       number: "123L",
      ...>       subject: %UnmClassScheduler.Catalog.Subject{
      ...>         code: "SUBJ"
      ...>       }
      ...>     }
      ...>   }
      ...> )
      {:ok, %{section_uuid: "SEC12345", crosslist_uuid: "SEC67890"}}

      iex> UnmClassScheduler.Catalog.Crosslist.validate_data(
      ...>   %{course_number: "123L", subject_code: "SUBJ"},
      ...>   section: %UnmClassScheduler.Catalog.Section{uuid: "SEC12345"},
      ...>   crosslist: nil
      ...> )
      {:error, [crosslist_uuid: {"can't be blank", [validation: :required]}]}
  """
  @impl true
  @spec validate_data(valid_params(), valid_associations()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, section: %Section{} = section, crosslist: crosslist) do
    types = %{
      section_uuid: :string,
      crosslist_uuid: :string,
    }

    section_params = %{section_uuid: section.uuid}

    {%{}, types}
    |> cast(section_params, [:section_uuid])
    |> maybe_apply_crosslist(params, crosslist)
    |> validate_required([:section_uuid, :crosslist_uuid])
    |> ChangesetUtils.apply_if_valid()
  end

  defp maybe_apply_crosslist(changeset, _, nil) do
    # add_error(changeset, :crosslist, "A valid crosslist is required.")
    changeset
  end

  defp maybe_apply_crosslist(changeset, %{course_number: c, subject_code: s}, crosslist) do
    cond do
      !Ecto.assoc_loaded?(crosslist.course) ->
        # add_error(changeset, :crosslist, "The crosslist Course and Subject must be preloaded.")
        changeset
      !Ecto.assoc_loaded?(crosslist.course.subject) ->
        # add_error(changeset, :crosslist, "The crosslist Course and Subject must be preloaded.")
        changeset
      crosslist.course.number != c or crosslist.course.subject.code != s ->
        # add_error(changeset, :crosslist, "The given crosslist does not match the given params.")
        changeset
      true ->
        cast(changeset, %{crosslist_uuid: crosslist.uuid}, [:crosslist_uuid])
    end
  end

  @impl true
  @spec conflict_keys :: list(atom())
  def conflict_keys(), do: [:section_uuid, :crosslist_uuid]
end
