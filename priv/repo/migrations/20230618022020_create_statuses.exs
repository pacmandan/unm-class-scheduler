defmodule UnmClassScheduler.Repo.Migrations.CreateStatuses do
  use Ecto.Migration

  def change do
    create table(:statuses, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string, null: false
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:statuses, [:code])
  end
end
