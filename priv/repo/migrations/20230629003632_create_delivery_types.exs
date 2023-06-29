defmodule UnmClassScheduler.Repo.Migrations.CreateDeliveryTypes do
  use Ecto.Migration

  def change do
    create table(:delivery_types, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :code, :string, null: false
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:delivery_types, [:code])
  end
end
