defmodule UnmClassScheduler.Catalog.MeetingTime do
  @moduledoc """
  Data representing a specific time, place, and weekdays.

  Each section has multiple meeting times associated.
  The "index" on each meeting time is the index as it relates to the linked section.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Serializable

  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils
  alias UnmClassScheduler.Catalog.Section
  alias UnmClassScheduler.Catalog.Building

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
    uuid: String.t(),
    start_date: Date.t(),
    end_date: Date.t(),
    start_time: Time.t(),
    end_time: Time.t(),
    sunday: boolean(),
    monday: boolean(),
    tuesday: boolean(),
    wednesday: boolean(),
    thursday: boolean(),
    friday: boolean(),
    saturday: boolean(),
    room: String.t(),
    index: integer(),
    section: Section.t(),
    section_uuid: String.t(),
    building: Building.t(),
    building_uuid: String.t(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @type valid_params :: %{
    start_date: Date.t(),
    end_date: Date.t(),
    start_time: Time.t(),
    end_time: Time.t(),
    sunday: boolean(),
    monday: boolean(),
    tuesday: boolean(),
    wednesday: boolean(),
    thursday: boolean(),
    friday: boolean(),
    saturday: boolean(),
    room: String.t(),
    index: integer(),
  }

  @type valid_associations :: [
    {:section, Section.t()},
    {:building, Building.t()},
  ]

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

  @doc """
  Validates given data without creating a Schema.

  ## Examples
  """
  # TODO: Examples
  @spec validate_data(valid_params(), valid_associations()) :: SchemaUtils.maybe_valid_changes()
  @impl true
  def validate_data(params, section: section, building: building) do
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

    {%{}, types}
    |> cast(params, Map.keys(types))
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
      :index,
    ])
    |> SchemaUtils.apply_association_uuids(%{section_uuid: section}, %{building_uuid: building})
    |> SchemaUtils.apply_changeset_if_valid()
  end

  @impl true
  def conflict_keys(), do: [
    :section_uuid,
    :index,
    :start_date,
    :end_date,
  ]

  @spec serialize_days_list(__MODULE__.t()) :: list(String.t())
  defp serialize_days_list(meeting_time) do
    Map.take(meeting_time, Map.keys(@day_mapping))
    |> Enum.reduce([], fn {day, available}, acc ->
      if available do
        [@day_mapping[day] | acc]
      else
        acc
      end
    end)
  end

  @spec serialize(__MODULE__.t()) :: map()
  @impl true
  def serialize(meeting_time) do
    %{
      start_date: meeting_time.start_date,
      end_date: meeting_time.end_date,
      start_time: meeting_time.start_time,
      end_time: meeting_time.end_time,
      sunday: meeting_time.sunday,
      monday: meeting_time.monday,
      tuesday: meeting_time.tuesday,
      wednesday: meeting_time.wednesday,
      thursday: meeting_time.thursday,
      friday: meeting_time.friday,
      saturday: meeting_time.saturday,
      room: meeting_time.room,
      days: serialize_days_list(meeting_time),
      building: Building.serialize(meeting_time.building)
    }
  end
end
