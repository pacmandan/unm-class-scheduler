defmodule UnmClassScheduler.ScheduleParserTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use UnmClassScheduler.DataCase

  import Mox
  import UnmClassScheduler.Factory

  alias UnmClassScheduler.ScheduleParser

  doctest UnmClassScheduler.ScheduleParser

  setup :verify_on_exit!

  setup do
    init_static_tables()

    :ok
  end

  test "sample XML loads and imports correctly" do
    UnmClassScheduler.ScheduleParser.MockFileDownloader
    |> expect(:download_all, fn _urls -> {:ok, ["./test/support/samplexml.xml"]} end)
    |> expect(:cleanup_files, fn _files -> :ok end)

    assert :ok == ScheduleParser.download_and_run(["fakeurl"])

    # The actual Updater module has more tests. This only assures the correct number were inserted
    # based on assumptions from the samplexml file.
    assert Repo.all(UnmClassScheduler.Catalog.Semester) |> length == 1
    assert Repo.all(UnmClassScheduler.Catalog.Campus) |> length == 2
    assert Repo.all(UnmClassScheduler.Catalog.Building) |> length == 4
    assert Repo.all(UnmClassScheduler.Catalog.College) |> length == 2
    assert Repo.all(UnmClassScheduler.Catalog.Department) |> length == 2
    assert Repo.all(UnmClassScheduler.Catalog.Subject) |> length == 2
    assert Repo.all(UnmClassScheduler.Catalog.Course) |> length == 5
    assert Repo.all(UnmClassScheduler.Catalog.Section) |> length == 6
    assert Repo.all(UnmClassScheduler.Catalog.Instructor) |> length == 3
    assert Repo.all(UnmClassScheduler.Catalog.InstructorSection) |> length == 7
    assert Repo.all(UnmClassScheduler.Catalog.MeetingTime) |> length == 7
    assert Repo.all(UnmClassScheduler.Catalog.Crosslist) |> length == 2
  end
end
