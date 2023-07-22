defmodule UnmClassScheduler.Search do
  alias UnmClassScheduler.Search.SectionResult
  alias UnmClassScheduler.Search.BuildQuery
  alias UnmClassScheduler.Repo

  def find_sections(params) do
    params
    |> BuildQuery.run()
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
