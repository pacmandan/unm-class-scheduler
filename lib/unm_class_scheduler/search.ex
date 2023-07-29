defmodule UnmClassScheduler.Search do
  @moduledoc """
  Search Context

  Main context module for performing a section search.
  """

  alias UnmClassScheduler.Search.SectionResult
  alias UnmClassScheduler.Search.Request
  alias UnmClassScheduler.Search.BuildQuery
  alias UnmClassScheduler.Repo

  @doc """
  Performs a search request, preloads all connected records, and formats
  the Sections as fully populated SectionResults.
  """
  @spec find_sections(Request.t()) :: list(SectionResult.t())
  def find_sections(params) do
    params
    |> BuildQuery.build()
    |> Repo.all()
    |> Repo.preload([
      :part_of_term,
      :status,
      :delivery_type,
      :instructional_method,
      :campus,
      :semester,
      instructors: :instructor,
      meeting_times: :building,
      course: [subject: [department: :college]],
      crosslists: [course: :subject]
    ])
    |> Enum.map(&SectionResult.build/1)
  end
end
