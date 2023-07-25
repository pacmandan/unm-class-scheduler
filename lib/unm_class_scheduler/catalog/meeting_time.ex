defmodule UnmClassScheduler.Catalog.MeetingTime do
  @moduledoc """
  Data representing a specific time, place, and weekdays.

  Each section has multiple meeting times associated.
  The "index" on each meeting time is the index as it relates to the linked section.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Serializable

  alias UnmClassScheduler.Utils.ChangesetUtils
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

  @typedoc """
  The map structure intended for display to a user.
  Omits UUIDs and timestamps, but keeps the building association.
  Also includes an additional "days" list, compressing all active days
  into a string array.
  """
  @type serialized_t :: %{
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
    days: list(String.t()),
    building: Building.serialized_t(),
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

  @doc """
  Converts a string representation of a day into an atomic one.
  Returns nil if the string doesn't represent a day.

  Days are mapped to single letters:
    sunday: "U"
    monday: "M"
    tuesday: "T"
    wednesday: "W"
    thursday: "R"
    friday: "F"
    saturday: "S"

  ## Examples
      iex> MeetingTime.day_from_string("T")
      :tuesday

      iex> MeetingTime.day_from_string("X")
      nil
  """
  @spec day_from_string(String.t()) :: atom() | nil
  def day_from_string(day) do
    @inverse_day_mapping[day]
  end

  @doc """
  Creates an initial mapping of days, all set to false.

      iex> MeetingTime.init_days()
      %{
        sunday: false,
        monday: false,
        tuesday: false,
        wednesday: false,
        thursday: false,
        friday: false,
        saturday: false,
      }
  """
  @spec init_days() :: %{atom() => false}
  def init_days() do
    Map.keys(@day_mapping)
    |> Enum.map((&({&1, false})))
    |> Enum.into(%{})
  end

  @doc """
  Validates given data without creating a Schema.

  ## Examples
      iex> data = %{
      ...>   sunday: false, monday: false, tuesday: false,
      ...>   wednesday: false, thursday: false, friday: false,
      ...>   saturday: false,
      ...>   start_date: ~D[2023-06-08], end_date: ~D[2024-06-08],
      ...>   start_time: ~T[10:00:00], end_time: ~T[11:00:00],
      ...>   room: "100", index: 0,
      ...> }
      iex> section = %Section{uuid: "SEC12345"}
      iex> building = %Building{uuid: "BLDG12345"}
      iex> MeetingTime.validate_data(data, building: building, section: section)
      {:ok, %{
        sunday: false, monday: false, tuesday: false,
        wednesday: false, thursday: false, friday: false,
        saturday: false,
        start_date: ~D[2023-06-08], end_date: ~D[2024-06-08],
        start_time: ~T[10:00:00], end_time: ~T[11:00:00],
        room: "100", index: 0,
        section_uuid: "SEC12345", building_uuid: "BLDG12345",
      }}
  """
  @impl true
  @spec validate_data(valid_params(), valid_associations()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, associations) do
    %{section: section, building: building} = Map.new(associations)
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
    |> ChangesetUtils.apply_association_uuids(%{section_uuid: section}, %{building_uuid: building})
    |> ChangesetUtils.apply_if_valid()
  end

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> MeetingTime.conflict_keys()
      [:section_uuid, :index, :start_date, :end_date]
  """
  @impl true
  @spec conflict_keys() :: list(atom())
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

  @days_index %{
    "U" => 0,
    "M" => 1,
    "T" => 2,
    "W" => 3,
    "R" => 4,
    "F" => 5,
    "S" => 6,
  }
  @spec sort_days(list(String.t())) :: list(String.t())
  defp sort_days(days) do
    Enum.sort(days, fn a, b ->
      @days_index[a] <= @days_index[b]
    end)
  end

  @doc """
  Transforms a MeetingTime into a normal map intended for display to a user.

  This will include the serialized Building, if one exists.

  This will also include a list of `:days`, which flattens the individual
  day booleans into a list of active days for the meeting time.
  ```
  %{tuesday: true, thursday: true} --> ["T", "R"]
  ```

  ## Examples
      iex> mt = %MeetingTime{
      ...>   uuid: "MT12345",
      ...>   sunday: false, monday: true, tuesday: false,
      ...>   wednesday: true, thursday: false, friday: true,
      ...>   saturday: false,
      ...>   start_date: ~D[2023-06-08], end_date: ~D[2024-06-08],
      ...>   start_time: ~T[10:00:00], end_time: ~T[11:00:00],
      ...>   room: "100", index: 0,
      ...>   building: %Building{code: "BLDG", name: "Test Building"},
      ...>   section: %Section{crn: "12345"},
      ...> }
      iex> MeetingTime.serialize(mt)
      %{
        sunday: false, monday: true, tuesday: false,
        wednesday: true, thursday: false, friday: true,
        saturday: false,
        days: ["M", "W", "F"],
        start_date: ~D[2023-06-08], end_date: ~D[2024-06-08],
        start_time: ~T[10:00:00], end_time: ~T[11:00:00],
        room: "100",
        building: %{code: "BLDG", name: "Test Building"},
      }
  """
  @impl true
  @spec serialize(t()) :: serialized_t()
  def serialize(nil), do: nil
  def serialize(%Ecto.Association.NotLoaded{}), do: nil
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
      days: serialize_days_list(meeting_time) |> sort_days,
      building: Building.serialize(meeting_time.building)
    }
  end
end
