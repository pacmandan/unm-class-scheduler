defmodule UnmClassScheduler.Repo.Migrations.CreateMeetingTimes do
  use Ecto.Migration

  def change do
    create table(:meeting_times, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :section_uuid, references(:sections, column: :uuid, type: :uuid), null: false
      add :start_date, :date
      add :end_date, :date
      add :start_time, :time
      add :end_time, :time
      add :sunday, :boolean
      add :monday, :boolean
      add :tuesday, :boolean
      add :wednesday, :boolean
      add :thursday, :boolean
      add :friday, :boolean
      add :saturday, :boolean

      add :building_uuid, references(:buildings, column: :uuid, type: :uuid)
      add :room, :string
      timestamps()
    end

    create unique_index(:meeting_times, [
      :section_uuid,
      :start_time,
      :end_time,
      :sunday,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
    ])
  end
end
