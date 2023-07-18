defmodule UnmClassSchedulerWeb.SearchController do
  use UnmClassSchedulerWeb, :controller

  def get(conn, %{"semester" => _} = params) do
    opts = %{
      page: case Integer.parse(params["page"] || "1") do
        :error -> 0
        {p, _} when p < 1 -> 0
        {p, _} -> p - 1
      end,
      per_page: case Integer.parse(params["perPage"] || "10") do
        :error -> 10
        {p, _} when p < 1 -> 1
        {p, _} -> p
      end
    }
    results = validate_params(params)
    |> UnmClassScheduler.Api.Search.find_sections(opts)

    json(conn, %{
      results: results,
      page: opts[:page] + 1,
      perPage: opts[:per_page]
    })
  end

  @param_keys %{
    "semester" => :semester,
    "campus" => :campus,
    "subject" => :subject,
    "course" => :course,
    "crn" => :crn,
  }

  defp validate_params(params) do
    params
    |> Enum.into(%{}, fn {string_key, v} ->
      {@param_keys[string_key], v}
    end)
  end
end
