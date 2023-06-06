defmodule UnmClassScheduler.Catalog.College do
  use UnmClassScheduler.Schema

  import Ecto.Changeset

  schema "colleges" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  def changeset(college, attrs) do
    college
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end
end
