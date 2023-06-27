defmodule UnmClassScheduler.Catalog.Building do
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Child

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Catalog.Campus

  schema "buildings" do
    field :code, :string
    field :name, :string

    belongs_to :campus, Campus, references: :uuid, foreign_key: :campus_uuid

    timestamps()
  end

  @impl true
  def validate_data(params, campus: campus) do
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

  @impl true
  def parent_module(), do: Campus

  @impl true
  def parent_key(), do: :campus

  @impl true
  def get_parent(building), do: building.campus

  @impl true
  def conflict_keys(), do: [:code, :campus_uuid]
end
