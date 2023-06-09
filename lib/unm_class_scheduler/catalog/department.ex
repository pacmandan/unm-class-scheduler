defmodule UnmClassScheduler.Catalog.Department do
  use UnmClassScheduler.Schema

  alias UnmClassScheduler.Catalog.{College}

  import Ecto.Changeset

  schema "departments" do
    field :code, :string
    field :name, :string

    belongs_to :college, College, references: :uuid, foreign_key: :college_uuid

    timestamps()
  end

  def changeset(department, attrs) do
    department
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end
end
