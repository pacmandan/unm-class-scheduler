defmodule UnmClassScheduler.Catalog.Campus do
  @moduledoc """
  Data representing a particular UNM campus location.

  This does not necessarily represent a physical location, as
  UNM has an "Online & ITV" campus for fully online classes.

  Has a uniquely identifying code and a name.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Serializable

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Utils.ChangesetUtils
  alias UnmClassScheduler.Catalog.Building

  @type t :: %__MODULE__{
    uuid: String.t(),
    code: String.t(),
    name: String.t(),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @type serialized_t :: %{
    code: String.t(),
    name: String.t(),
  }

  @type valid_params :: %{
    code: String.t(),
    name: String.t(),
  }

  schema "campuses" do
    field :code, :string
    field :name, :string

    has_many :buildings, Building, references: :uuid, foreign_key: :campus_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  Campuses have no parent associations, so anything passed to those is ignored.

  ## Examples
      iex> UnmClassScheduler.Catalog.Campus.validate_data(%{code: "CAM", name: "Test Campus"})
      {:ok, %{code: "CAM", name: "Test Campus"}}

      iex> UnmClassScheduler.Catalog.Campus.validate_data(%{"code" => "CAM", "name" => "Test Campus"})
      {:ok, %{code: "CAM", name: "Test Campus"}}

      iex> UnmClassScheduler.Catalog.Campus.validate_data(%{code: "CAM", name: "Test Campus", extra: "value"})
      {:ok, %{code: "CAM", name: "Test Campus"}}

      iex> UnmClassScheduler.Catalog.Campus.validate_data(%{code: "CAM"})
      {:error, [name: {"can't be blank", [{:validation, :required}]}]}
  """
  @spec validate_data(valid_params(), any()) :: ChangesetUtils.maybe_valid_changes()
  @impl true
  def validate_data(params, _associations \\ []) do
    types = %{code: :string, name: :string}

    {%{}, types}
    |> cast(params, [:code, :name])
    |> validate_required([:code, :name])
    |> ChangesetUtils.apply_if_valid()
  end

  @impl true
  def conflict_keys(), do: :code

  @spec serialize(__MODULE__.t()) :: __MODULE__.serialized_t()
  @impl true
  def serialize(nil), do: nil
  def serialize(data) do
    %{
      code: data.code,
      name: data.name,
    }
  end
end
