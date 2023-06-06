defmodule UnmClassScheduler.Catalog.Campus do
  use UnmClassScheduler.Schema

  import Ecto.Changeset

  schema "campuses" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  def changeset(campus, attrs) do
    campus
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end
end
