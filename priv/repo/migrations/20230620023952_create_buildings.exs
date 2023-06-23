defmodule UnmClassScheduler.Repo.Migrations.CreateBuildings do
  use Ecto.Migration

  def change do
    create table(:buildings, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string, null: false
      add :name, :string, null: false
      add :campus_uuid, references(:campuses, column: :uuid, type: :uuid), null: false
      timestamps()
    end

    create unique_index(:buildings, [:code, :campus_uuid])
  end
end
