defmodule UnmClassScheduler.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :number, :string, null: false
      add :title, :string
      add :subject_uuid, references(:subjects, column: :uuid, type: :uuid), null: false
      add :catalog_description, :text

      timestamps()
    end

    create unique_index(:courses, [:subject_uuid, :number])
  end
end
