defmodule UnmClassScheduler.Repo.Migrations.AddCampusToSections do
  use Ecto.Migration

  def change do
    alter table(:sections) do
      add :campus_uuid, references(:campuses, column: :uuid, type: :uuid), null: false
    end
  end
end
