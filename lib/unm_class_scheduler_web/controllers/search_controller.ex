defmodule UnmClassSchedulerWeb.SearchController do
  alias UnmClassScheduler.Search.Request

  use UnmClassSchedulerWeb, :controller

  def get(conn, params) do
    case Request.prepare(params) do
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
end
