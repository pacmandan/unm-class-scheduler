defmodule UnmClassScheduler.Repo.Migrations.CreatePartsOfTerm do
  use Ecto.Migration

  def change do
    create table(:parts_of_term, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string, null: false
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:parts_of_term, [:code])
  end
end
