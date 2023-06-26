defmodule UnmClassScheduler.Catalog.Semester do
  use UnmClassScheduler.Schema, conflict_keys: :code

  import Ecto.Changeset

  schema "semesters" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  def changeset(semester, attrs) do
    semester
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
