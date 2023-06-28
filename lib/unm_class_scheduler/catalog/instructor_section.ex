defmodule UnmClassScheduler.Catalog.InstructorSection do
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Catalog.Section
  alias UnmClassScheduler.Catalog.Instructor

  schema "instructors_sections" do
    field :primary, :boolean, default: false
    belongs_to :section, Section, references: :uuid, foreign_key: :section_uuid
    belongs_to :instructor, Instructor, references: :uuid, foreign_key: :instructor_uuid

    timestamps()
  end

  @impl true
  def validate_data(params, section: %Section{} = section, instructor: %Instructor{} = instructor) do
    data = %{}
    types = %{
      primary: :boolean,
      section_uuid: :string,
      instructor_uuid: :string,
    }

    all_params = params
    |> Map.merge(%{
      section_uuid: section.uuid,
      instructor_uuid: instructor.uuid,
    })

    cs = {data, types}
    |> cast(all_params, Map.keys(types))
    |> validate_required([:section_uuid, :instructor_uuid])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end

  @impl true
  def conflict_keys(), do: [:section_uuid, :instructor_uuid]
end
