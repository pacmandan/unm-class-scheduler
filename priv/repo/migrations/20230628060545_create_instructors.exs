defmodule UnmClassScheduler.Repo.Migrations.CreateInstructors do
  use Ecto.Migration

  def change do
    create table(:instructors, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :first, :string, null: false
      add :last, :string, null: false
      add :middle_initial, :string
      add :email, :string, null: false

      timestamps()
    end

    # Emails are not unique - some instructors are listed as "No UNM email address"
    create unique_index(:instructors, [:email, :first, :last])
  end
end
