defmodule UnmClassScheduler.Repo.Migrations.CreateColleges do
  use Ecto.Migration

  def change do
    create table(:colleges, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string, null: false
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:colleges, [:code])
  end
end
