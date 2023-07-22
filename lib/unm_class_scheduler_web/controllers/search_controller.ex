defmodule UnmClassSchedulerWeb.SearchController do
  alias UnmClassScheduler.Schema.Utils, as: SchemaUtils
  use UnmClassSchedulerWeb, :controller

  def get(conn, params) do
    case prepare(params) do
      {:ok, params} ->
        results = UnmClassScheduler.Search.find_sections(params)
        json(conn, %{
          results: results,
        })
      {:error, _} ->
        # TODO: Better error messages
        conn
        |> put_status(400)
        |> json(%{error: "There was a problem."})
    end
  end

  def prepare(params) do
    changeset(params)
    |> SchemaUtils.apply_changeset_if_valid()
  end

  @spec changeset(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          Ecto.Changeset.t()
  def changeset(params) do
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
  end
end
