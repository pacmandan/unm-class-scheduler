defmodule UnmClassScheduler.Catalog.College do
  use UnmClassScheduler.Schema

  alias UnmClassScheduler.Catalog.{Department}

  import Ecto.Changeset

  schema "colleges" do
    field :code, :string
    field :name, :string

    has_many :departments, Department, references: :uuid, foreign_key: :college_uuid

    timestamps()
  end

  def changeset(college, attrs) do
    college
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end
end
