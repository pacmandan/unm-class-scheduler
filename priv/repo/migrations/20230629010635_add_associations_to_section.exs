defmodule UnmClassScheduler.Repo.Migrations.AddAssociationsToSection do
  use Ecto.Migration

  def change do
    alter table(:sections) do
      add :delivery_type_uuid, references(:delivery_types, column: :uuid, type: :uuid)
      add :instructional_method_uuid, references(:instructional_methods, column: :uuid, type: :uuid)
    end
  end
end
