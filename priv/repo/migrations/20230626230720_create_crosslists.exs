defmodule UnmClassScheduler.Repo.Migrations.CreateCrosslists do
  use Ecto.Migration

  def change do
    create table(:crosslists, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :section_uuid, references(:sections, column: :uuid, type: :uuid)
      add :crosslist_uuid, references(:sections, column: :uuid, type: :uuid)

      timestamps()
    end

    create unique_index(:crosslists, [:section_uuid, :crosslist_uuid])
  end
end
