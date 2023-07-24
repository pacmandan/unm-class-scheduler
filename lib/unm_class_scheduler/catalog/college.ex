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

  @typedoc """
  The map structure intended for display to a user.
  Omits UUIDs and timestamps.
  """
  @type serialized_t :: %{
    code: String.t(),
    name: String.t(),
  }

  @type valid_params :: serialized_t()

  schema "colleges" do
    field :code, :string
    field :name, :string

    has_many :departments, Department, references: :uuid, foreign_key: :college_uuid

    timestamps()
  end

  @doc """
  Validates given data without creating a Schema.

  Colleges have no parent associations, so any second parameter to `validate_data/2` is ignored.

  Required parameters are `:code` and `:name`.

  ## Examples
      iex> College.validate_data(%{code: "COL", name: "Test College"})
      {:ok, %{code: "COL", name: "Test College"}}

      iex> College.validate_data(%{code: "COL"})
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

  @doc """
  When inserting records from this Schema, this is the `conflict_target` to
  use for detecting collisions.

      iex> College.conflict_keys()
      :code
  """
  @impl true
  @spec conflict_keys() :: atom()
  def conflict_keys(), do: :code

  @doc """
  Transforms a College into a normal map intended for display to a user.

  ## Examples
      iex> College.serialize(%College{code: "COL", name: "Test College"})
      %{code: "COL", name: "Test College"}
  """
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
