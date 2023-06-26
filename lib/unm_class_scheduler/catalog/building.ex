defmodule UnmClassScheduler.Catalog.Building do
  alias UnmClassScheduler.Catalog.{
    Campus,
  }

  use UnmClassScheduler.Schema, conflict_keys: [:code, :campus_uuid]
  use UnmClassScheduler.Schema.Child, parent: Campus

  import Ecto.Changeset

  schema "buildings" do
    field :code, :string
    field :name, :string

    belongs_to :campus, Campus, references: :uuid, foreign_key: :campus_uuid

    timestamps()
  end

  def changeset(building, attrs) do
    building
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end

  def validate(params, campus) do
    data = %{}
    types = %{code: :string, name: :string, campus_uuid: :string}
    cs = {data, types}
    |> cast(params |> Map.merge(%{campus_uuid: campus.uuid}), [:code, :name, :campus_uuid])
    |> validate_required([:code, :name])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end

  def parent_key(), do: :campus

  def parent(building), do: building.campus
end
