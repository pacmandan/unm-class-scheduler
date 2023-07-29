defmodule UnmClassScheduler.ScheduleParser.ExtractedItemTest do
    @moduledoc false
    use ExUnit.Case, async: true
    use UnmClassScheduler.DataCase

    alias UnmClassScheduler.ScheduleParser.ExtractedItem
    alias UnmClassScheduler.Catalog.Semester
    alias UnmClassScheduler.Catalog.Campus

    doctest UnmClassScheduler.ScheduleParser.ExtractedItem
end
