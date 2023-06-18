defmodule UnmClassScheduler.Repo.Migrations.CreateSections do
  use Ecto.Migration

  def change do
    create table(:sections, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :crn, :string, null: false
      add :number, :string, null: false
      add :title, :string
      add :enrollment, :integer
      add :enrollment_max, :integer
      add :waitlist, :integer
      add :waitlist_max, :integer
      add :credits, :string
      add :fees, :float
      add :text, :text

      add :part_of_term_uuid, references(:parts_of_term, column: :uuid, type: :uuid), null: false
      add :status_uuid, references(:statuses, column: :uuid, type: :uuid), null: false
      add :semester_uuid, references(:semesters, column: :uuid, type: :uuid), null: false
      add :course_uuid, references(:courses, column: :uuid, type: :uuid), null: false

      # TODO: All the rest of the section fields

      timestamps()
    end

    create unique_index(:sections, [:crn, :semester_uuid])
  end
end
