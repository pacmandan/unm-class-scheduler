defmodule UnmClassScheduler.Repo.Migrations.AddSectionCredits do
  use Ecto.Migration

  def change do
    alter table(:sections) do
      add :credits_min, :integer
      add :credits_max, :integer
    end
  end
end
