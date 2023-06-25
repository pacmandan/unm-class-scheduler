defmodule UnmClassScheduler.Catalog.MeetingTime do
  alias UnmClassScheduler.Catalog.{
    Section,
    Building,
  }

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

  use UnmClassScheduler.Schema, conflict_keys: []

  import Ecto.Changeset

  schema "sections" do
    field :start_date, :date
    field :end_date, :date
    field :start_time, :time
    field :end_time, :time
    field :days, {:array, :string}, virtual: true
    field :sunday, :boolean
    field :monday, :boolean
    field :tuesday, :boolean
    field :wednesday, :boolean
    field :thursday, :boolean
    field :friday, :boolean
    field :saturday, :boolean
    field :room, :string

    belongs_to :building, Building, references: :uuid, foreign_key: :building_uuid
    belongs_to :section, Section, references: :uuid, foreign_key: :section_uuid
    timestamps()
  end

  def create_meeting_time(attrs, section) do
    Ecto.build_assoc(section, :meeting_times)
    |> cast(attrs, [:start_date, :end_date, :start_time, :end_time, :room])
  end

  defp init_days() do
    Map.keys(@day_mapping)
    |> Enum.each((&({&1, false})))
    |> Enum.into(%{})
  end

  def days_from_strings(days) do
    days
    |> Enum.reduce(init_days(), fn day, acc ->
      Map.put(acc, @inverse_day_mapping[day], true)
    end)
  end
end
