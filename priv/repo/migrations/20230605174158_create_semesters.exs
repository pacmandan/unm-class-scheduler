defmodule UnmClassScheduler.Repo.Migrations.CreateSemesters do
  use Ecto.Migration

  def change do
    create table(:semesters, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string
      add :name, :string
      timestamps()
    end

    create unique_index(:semesters, [:code])
  end
end
