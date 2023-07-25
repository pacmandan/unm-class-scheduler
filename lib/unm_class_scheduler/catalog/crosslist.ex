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
      iex> Crosslist.validate_data(
      ...>   %{course_number: "123L", subject_code: "SUBJ"},
      ...>   section: %Section{uuid: "SEC12345"},
      ...>   crosslist: %Section{
      ...>     uuid: "SEC67890",
      ...>     course: %Course{
      ...>       number: "123L",
      ...>       subject: %Subject{
      ...>         code: "SUBJ"
      ...>       }
      ...>     }
      ...>   }
      ...> )
      {:ok, %{section_uuid: "SEC12345", crosslist_uuid: "SEC67890"}}

      iex> Crosslist.validate_data(
      ...>   %{course_number: "123L", subject_code: "SUBJ"},
      ...>   section: %Section{uuid: "SEC12345"},
      ...>   crosslist: nil
      ...> )
      {:error, [crosslist_uuid: {"can't be blank", [validation: :required]}]}
  """
  @impl true
  @spec validate_data(valid_params(), valid_associations()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, section: section, crosslist: crosslist) do
    types = %{
      section_uuid: :string,
      crosslist_uuid: :string,
    }

    {%{}, types}
    |> cast(%{}, [])
    |> ChangesetUtils.apply_association_uuids(%{section_uuid: section})
    |> maybe_apply_crosslist(params, crosslist)
    |> validate_required([:crosslist_uuid])
    |> ChangesetUtils.apply_if_valid()
  end

  defp maybe_apply_crosslist(changeset, _, nil) do
    # add_error(changeset, :crosslist, "A valid crosslist is required.")
    changeset
  end

  defp maybe_apply_crosslist(changeset, %{course_number: c, subject_code: s}, crosslist) do
    cond do
      !Ecto.assoc_loaded?(crosslist.course) ->
        add_error(changeset, :crosslist, "crosslist Course and Subject must be preloaded")
      !Ecto.assoc_loaded?(crosslist.course.subject) ->
        add_error(changeset, :crosslist, "crosslist Course and Subject must be preloaded")
      crosslist.course.number != c ->
        add_error(changeset, :course_number, "crosslist course does not match param course")
      crosslist.course.subject.code != s ->
        add_error(changeset, :subject_code, "crosslist subject does not match param subject")
      true ->
        cast(changeset, %{crosslist_uuid: crosslist.uuid}, [:crosslist_uuid])
    end
  end

  defp maybe_apply_crosslist(changeset, params, _) when not is_map_key(params, :subject_code) do
    add_error(changeset, :subject_code, "missing validation param")
  end

  defp maybe_apply_crosslist(changeset, params, _) when not is_map_key(params, :course_number) do
    add_error(changeset, :course_number, "missing validation param")
  end


  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> Crosslist.conflict_keys()
      [:section_uuid, :crosslist_uuid]
  """
  @impl true
  @spec conflict_keys :: list(atom())
  def conflict_keys(), do: [:section_uuid, :crosslist_uuid]
end
