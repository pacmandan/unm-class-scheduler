defmodule UnmClassScheduler.Catalog.College do
  use UnmClassScheduler.Schema, conflict_keys: :code
  use UnmClassScheduler.Schema.Parent, child: :departments

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

  def validate(params) do
    data = %{}
    types = %{code: :string, name: :string}
    cs = {data, types}
    |> cast(params, [:code, :name])
    |> validate_required([:code, :name])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end
end
