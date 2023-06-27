defmodule UnmClassScheduler.Catalog.College do
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Catalog.Department

  schema "colleges" do
    field :code, :string
    field :name, :string

    has_many :departments, Department, references: :uuid, foreign_key: :college_uuid

    timestamps()
  end

  @impl true
  def validate_data(params, _associations \\ []) do
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

  @impl true
  def conflict_keys(), do: :code
end
