defmodule UnmClassScheduler.Catalog.College do
  @moduledoc """
  Data representing a "College" at UNM.

  UNM groups its Subjects into Departments, which are further grouped into Colleges.

  Has a uniquely identifying code and a name.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils
  alias UnmClassScheduler.Catalog.Department

  @type t :: %__MODULE__{
    uuid: String.t(),
    code: String.t(),
    name: String.t(),
    departments: list(Department.t()),
    inserted_at: NaiveDateTime.t(),
    updated_at: NaiveDateTime.t(),
  }

  schema "colleges" do
    field :code, :string
    field :name, :string

    has_many :departments, Department, references: :uuid, foreign_key: :college_uuid

    timestamps()
  end

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
  @spec validate_data(map(), any()) :: {:ok, map()} | {:error, [{atom(), Ecto.Changeset.error()}]}
  @impl true
  def validate_data(params, _associations \\ []) do
    types = %{code: :string, name: :string}

    {%{}, types}
    |> cast(params, [:code, :name])
    |> validate_required([:code, :name])
    |> SchemaUtils.apply_changeset_if_valid()
  end

  @impl true
  def conflict_keys(), do: :code
end
