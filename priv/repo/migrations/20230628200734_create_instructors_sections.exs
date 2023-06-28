defmodule UnmClassScheduler.Repo.Migrations.CreateInstructorsSections do
  use Ecto.Migration

  def change do
    create table(:instructors_sections, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :section_uuid, references(:sections, column: :uuid, type: :uuid)
      add :instructor_uuid, references(:instructors, column: :uuid, type: :uuid)
      add :primary, :boolean, default: false

      timestamps()
    end

    create unique_index(:instructors_sections, [:section_uuid, :instructor_uuid])
  end
end
