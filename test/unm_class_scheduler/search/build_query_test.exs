defmodule UnmClassScheduler.Search.BuildQueryTest do
  @moduledoc false
  use ExUnit.Case, async: false
  use UnmClassScheduler.FactoryDefaultCase

  alias UnmClassScheduler.Search.BuildQuery

  doctest UnmClassScheduler.Search.BuildQuery

  describe "build/1" do
    test "with only semester params" do
      crns = %{semester: "202310"}
      |> BuildQuery.build()
      |> Repo.all()
      |> Enum.map(fn section -> section.crn end)

      assert crns == ["50001", "50002", "50003", "50004", "50005"]
    end

    test "with semester and campus params" do
      crns = %{semester: "202310", campus: "ABQ"}
      |> BuildQuery.build()
      |> Repo.all()
      |> Enum.map(fn section -> section.crn end)

      assert crns == ["50001", "50002", "50003", "50004"]
    end

    test "with semester, campus, and subject params" do
      crns = %{semester: "202310", campus: "ABQ", subject: "SUBJ2"}
      |> BuildQuery.build()
      |> Repo.all()
      |> Enum.map(fn section -> section.crn end)

      assert crns == ["50002", "50003", "50004"]
    end

    test "with semester, campus, subject, and course params" do
      crns = %{semester: "202310", campus: "ABQ", subject: "SUBJ2", course: "212"}
      |> BuildQuery.build()
      |> Repo.all()
      |> Enum.map(fn section -> section.crn end)

      assert crns == ["50003", "50004"]
    end

    test "with semester and crn params" do
      crns = %{semester: "202310", crn: "50001"}
      |> BuildQuery.build()
      |> Repo.all()
      |> Enum.map(fn section -> section.crn end)

      assert crns == ["50001"]
    end

    test "with an unknown key" do
      crns = %{semester: "202310", crn: "50001", unknown: "key"}
      |> BuildQuery.build()
      |> Repo.all()
      |> Enum.map(fn section -> section.crn end)

      assert crns == ["50001"]
    end
  end
end
