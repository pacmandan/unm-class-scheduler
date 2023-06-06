defmodule UnmClassScheduler.Repo.Migrations.CreateCampuses do
  use Ecto.Migration

  def change do
    create table(:campuses, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string
      add :name, :string
      timestamps()
    end

    create unique_index(:campuses, [:code])
  end
end
