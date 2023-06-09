defmodule UnmClassScheduler.Repo.Migrations.CreateSubjects do
  use Ecto.Migration

  def change do
    create table(:subjects, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string
      add :name, :string
      add :department_uuid, references(:departments, column: :uuid, type: :uuid)
      timestamps()
    end

    create unique_index(:subjects, [:code])
  end
end
