defmodule UnmClassScheduler.Catalog.Crosslist do
  use UnmClassScheduler.Schema, conflict_keys: [:section_uuid, :crosslist_uuid]

  alias UnmClassScheduler.Catalog.Section

  import Ecto.Changeset

  schema "crosslists" do
    belongs_to :section, Section, references: :uuid, foreign_key: :section_uuid
    belongs_to :crosslist, Section, references: :uuid, foreign_key: :crosslist_uuid

    timestamps()
  end

  def validate(params, section, crosslist) do
    data = %{}
    types = %{
      section_uuid: :string,
      crosslist_uuid: :string,
    }

    all_params = %{
      section_uuid: section.uuid,
    }

    cs = {data, types}
    |> cast(all_params, Map.keys(types))

    cs = if crosslist_exists?(params, crosslist) do
      cs
      |> cast(%{crosslist_uuid: crosslist.uuid}, Map.keys(types))
      |> validate_required([:section_uuid, :crosslist_uuid])
    else
      add_error(cs, :crosslist, "does not exist")
    end

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end

  defp crosslist_exists?(%{course_number: c, subject_code: s}, crosslist) do
    cond do
      is_nil(crosslist) ->
        false
      # So, it turns out, sometimes crosslists reference things that don't exist?
      # Fortunately they also list the course number and subject code in the crosslist,
      # so this serves to double-check the crosslisted section we found via CRN.
      crosslist.course.number != c or crosslist.course.subject.code != s ->
        false
      true ->
        true
    end
  end
end
