defmodule UnmClassScheduler.DBUpdater.ExtractedItemTest do
    @moduledoc false
    use ExUnit.Case, async: true
    use UnmClassScheduler.DataCase

    alias UnmClassScheduler.DBUpdater.ExtractedItem
    alias UnmClassScheduler.Catalog.Semester
    alias UnmClassScheduler.Catalog.Campus

    doctest UnmClassScheduler.DBUpdater.ExtractedItem
end
