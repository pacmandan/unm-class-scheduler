defmodule UnmClassScheduler.Catalog.Semester do
  @moduledoc """
  Data representing a particular semester at UNM.

  Has a uniquely identifying code and a name.
  """

  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts
  @behaviour UnmClassScheduler.Schema.Serializable

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils

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

  schema "semesters" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  Semesters have no parent associations, so anything passed to those is ignored.

  ## Examples
      iex> UnmClassScheduler.Catalog.Semester.validate_data(%{code: "TEST", name: "Test Semester"})
      {:ok, %{code: "TEST", name: "Test Semester"}}

      iex> UnmClassScheduler.Catalog.Semester.validate_data(%{"code" => "TEST", "name" => "Test Semester"})
      {:ok, %{code: "TEST", name: "Test Semester"}}

      iex> UnmClassScheduler.Catalog.Semester.validate_data(%{code: "TEST", name: "Test Semester", extra: "value"})
      {:ok, %{code: "TEST", name: "Test Semester"}}

      iex> UnmClassScheduler.Catalog.Semester.validate_data(%{code: "TEST"})
      {:error, [name: {"can't be blank", [{:validation, :required}]}]}
  """
  @spec validate_data(valid_params(), any()) :: SchemaUtils.maybe_valid_changes()
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
