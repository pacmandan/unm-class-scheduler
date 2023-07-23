defmodule UnmClassScheduler.Catalog.College do
  @moduledoc """
  Data representing a "College" at UNM.

  UNM groups its Subjects into Departments, which are further grouped into Colleges.

  Has a uniquely identifying code and a name.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Serializable

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Utils.ChangesetUtils
  alias UnmClassScheduler.Catalog.Department

  @type t :: %__MODULE__{
    uuid: String.t(),
    code: String.t(),
    name: String.t(),
    departments: list(Department.t()),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  @type valid_params :: %{
    code: String.t(),
    name: String.t(),
  }

  schema "colleges" do
    field :code, :string
    field :name, :string

    has_many :departments, Department, references: :uuid, foreign_key: :college_uuid

    timestamps()
  end

  # TODO: Move some of these tests out of doctest and into normal test files.
  # Anything in doctest should ONLY be relevant for documentation.

  @doc """
  Validates given data without creating a Schema.

  Colleges have no parent associations, so naything passed to those is ignored.
  ## Examples
      iex> UnmClassScheduler.Catalog.College.validate_data(%{code: "COL", name: "Test College"})
      {:ok, %{code: "COL", name: "Test College"}}

      iex> UnmClassScheduler.Catalog.College.validate_data(%{"code" => "COL", "name" => "Test College"})
      {:ok, %{code: "COL", name: "Test College"}}

      iex> UnmClassScheduler.Catalog.College.validate_data(%{code: "COL", name: "Test College", extra: "value"})
      {:ok, %{code: "COL", name: "Test College"}}

      iex> UnmClassScheduler.Catalog.College.validate_data(%{code: "COL"})
      {:error, [name: {"can't be blank", [{:validation, :required}]}]}
  """
  @impl true
  @spec validate_data(valid_params(), any()) :: ChangesetUtils.maybe_valid_changes()
  def validate_data(params, _associations \\ []) do
    types = %{code: :string, name: :string}

    {%{}, types}
    |> cast(params, [:code, :name])
    |> validate_required([:code, :name])
    |> ChangesetUtils.apply_if_valid()
  end

  @impl true
  def conflict_keys(), do: :code

  @impl true
  @spec serialize(__MODULE__.t()) :: map()
  def serialize(nil), do: nil
  def serialize(data) do
    %{
      code: data.code,
      name: data.name,
    }
  end
end
