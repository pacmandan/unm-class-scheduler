defmodule UnmClassScheduler.Repo.Migrations.CreateSemesters do
  use Ecto.Migration

  def change do
    create table(:semesters, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string, null: false
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:semesters, [:code])
  end
end
