defmodule UnmClassScheduler.ScheduleParser.UpdaterTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use UnmClassScheduler.DataCase

  alias UnmClassScheduler.ScheduleParser.Updater
  alias UnmClassScheduler.Catalog.Semester
  alias UnmClassScheduler.Catalog.Campus
  alias UnmClassScheduler.Catalog.Building
  alias UnmClassScheduler.Catalog.College
  alias UnmClassScheduler.Catalog.Department
  alias UnmClassScheduler.Catalog.Subject
  alias UnmClassScheduler.Catalog.Course
  alias UnmClassScheduler.Catalog.Section
  alias UnmClassScheduler.Catalog.MeetingTime
  alias UnmClassScheduler.Catalog.Crosslist
  alias UnmClassScheduler.Catalog.Instructor
  alias UnmClassScheduler.Catalog.InstructorSection
  alias UnmClassScheduler.Catalog.PartOfTerm
  alias UnmClassScheduler.Catalog.Status
  alias UnmClassScheduler.Catalog.InstructionalMethod
  alias UnmClassScheduler.Catalog.DeliveryType
  alias UnmClassScheduler.ScheduleParser.ExtractedItem, as: E

  doctest UnmClassScheduler.ScheduleParser.Updater

  describe "mass_insert/1" do
    test "inserts correctly into the database with valid params" do

    end
  end
end
