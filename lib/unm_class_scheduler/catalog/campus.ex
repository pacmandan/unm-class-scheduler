defmodule UnmClassScheduler.Catalog.Campus do
  use UnmClassScheduler.Schema, conflict_keys: :code
  use UnmClassScheduler.Schema.Parent, child: :buildings

  alias UnmClassScheduler.Catalog.{Building}

  import Ecto.Changeset

  schema "campuses" do
    field :code, :string
    field :name, :string

    has_many :buildings, Building, references: :uuid, foreign_key: :campus_uuid

    timestamps()
  end

  def changeset(campus, attrs) do
    campus
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end
end
