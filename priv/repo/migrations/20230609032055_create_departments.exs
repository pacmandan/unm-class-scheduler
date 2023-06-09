defmodule UnmClassScheduler.Repo.Migrations.CreateDepartments do
  use Ecto.Migration

  def change do
    create table(:departments, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string, null: false
      add :name, :string, null: false
      add :college_uuid, references(:colleges, column: :uuid, type: :uuid), null: false
      timestamps()
    end

    create unique_index(:departments, [:code])
  end
end
