defmodule UnmClassScheduler.Repo.Migrations.CreateInstructionalMethods do
  use Ecto.Migration

  def change do
    create table(:instructional_methods, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string, null: false
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:instructional_methods, [:code])
  end
end
