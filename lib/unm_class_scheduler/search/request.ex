defmodule UnmClassScheduler.Search.Request do
  @moduledoc """
  Request parameters to perform a section search.
  """

  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils

  @type t :: %{
    semester: String.t(),
    campus: String.t(),
    subject: String.t(),
    course: String.t(),
    crn: String.t(),
  }

  @doc """
  Takes the raw parameters from the controller, validates them,
  and coerces them into a Request type.
  """
  @spec prepare(map()) :: {:ok, __MODULE__.t()} | {:error, [{atom(), Ecto.Changeset.error()}]}
  def prepare(params) do
    types = %{
      semester: :string,
      campus: :string,
      subject: :string,
      course: :string,
      crn: :string,
    }
    {%{}, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:semester])
    |> SchemaUtils.apply_changeset_if_valid()
  end
end
