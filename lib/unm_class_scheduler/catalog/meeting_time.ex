defmodule UnmClassScheduler.Catalog.MeetingTime do
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  @day_mapping %{
    sunday: "U",
    monday: "M",
    tuesday: "T",
    wednesday: "W",
    thursday: "R",
    friday: "F",
    saturday: "S",
  }

  @inverse_day_mapping @day_mapping
    |> Map.new(fn {atom, string} -> {string, atom} end)

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Catalog.Section
  alias UnmClassScheduler.Catalog.Building

  schema "meeting_times" do
    field :start_date, :date
    field :end_date, :date
    field :start_time, :time
    field :end_time, :time
    field :sunday, :boolean
    field :monday, :boolean
    field :tuesday, :boolean
    field :wednesday, :boolean
    field :thursday, :boolean
    field :friday, :boolean
    field :saturday, :boolean
    field :room, :string
    field :index, :integer

    belongs_to :building, Building, references: :uuid, foreign_key: :building_uuid
    belongs_to :section, Section, references: :uuid, foreign_key: :section_uuid
    timestamps()
  end

  def day_from_string(day) do
    @inverse_day_mapping[day]
  end

  def init_days() do
    Map.keys(@day_mapping)
    |> Enum.map((&({&1, false})))
    |> Enum.into(%{})
  end

  @impl true
  def validate_data(params, section: section, building: building) do
    data = %{}
    types = %{
      start_date: :date,
      end_date: :date,
      start_time: :time,
      end_time: :time,
      sunday: :boolean,
      monday: :boolean,
      tuesday: :boolean,
      wednesday: :boolean,
      thursday: :boolean,
      friday: :boolean,
      saturday: :boolean,
      room: :string,
      building_uuid: :string,
      section_uuid: :string,
      index: :integer,
    }

    all_params =
      if is_nil(building) do
        params
        |> Map.merge(%{
          section_uuid: section.uuid,
        })
      else
        params
        |> Map.merge(%{
          section_uuid: section.uuid,
          building_uuid: building.uuid,
        })
      end


    cs = {data, types}
    |> cast(all_params, Map.keys(types))
    |> validate_required([
      :sunday,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
      :start_date,
      :end_date,
      :section_uuid,
      :index,
    ])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end

  @impl true
  def conflict_keys(), do: [
    :section_uuid,
    :index,
    :start_date,
    :end_date,
  ]
end
