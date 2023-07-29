defmodule UnmClassScheduler.SearchTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use UnmClassScheduler.DataCase

  alias UnmClassScheduler.Search
  alias UnmClassScheduler.Search.SectionResult

  doctest UnmClassScheduler.Search

  test "find_sections/1 builds query, returns section results" do
    params = %{semester: "202310", campus: "ABQ", subject: "SUBJ2", course: "212"}
    exptect_results = [
      %{
        campus: %{code: "ABQ", name: "Albuquerque/Main"},
        college: %{code: "COL2", name: "College 2"},
        course: %{catalog_description: "SUBJ2 212 description", number: "212", title: "Course 2.2"},
        credits_max: 3,
        credits_min: 3,
        crn: "50003",
        crosslists: [],
        delivery_type: %{code: "LC", name: "Lecture"},
        department: %{code: "DEP2", name: "Department 2"},
        enrollment: 0,
        enrollment_max: 0,
        fees: 0.0,
        instructional_method: %{code: "ENH", name: "Web Enhanced"},
        instructors: [%{email: "fperson@unm.edu", first: "Fake", last: "Person", middle_initial: "S", primary: true}],
        meeting_times: [%{building: %{code: "BLDG1", name: "Building 1"}, days: ["M", "W"], end_date: ~D[2023-06-25], end_time: ~T[15:50:00], friday: false, monday: true, room: "103", saturday: false, start_date: ~D[2023-03-01], start_time: ~T[15:00:00], sunday: false, thursday: false, tuesday: false, wednesday: true}],
        number: "001",
        part_of_term: %{code: "1", name: "Full Term"},
        semester: %{code: "202310", name: "Spring 2023"},
        status: %{code: "A", name: "Active"},
        subject: %{code: "SUBJ2", name: "Subject 2"},
        text: "",
        title: "",
        waitlist: 0,
        waitlist_max: 0,
      },
      %{
        campus: %{code: "ABQ", name: "Albuquerque/Main"},
        college: %{code: "COL2", name: "College 2"},
        course: %{catalog_description: "SUBJ2 212 description", number: "212", title: "Course 2.2"},
        credits_max: 3,
        credits_min: 3,
        crn: "50004",
        crosslists: [],
        delivery_type: %{code: "LC", name: "Lecture"},
        department: %{code: "DEP2", name: "Department 2"},
        enrollment: 0,
        enrollment_max: 0,
        fees: 0.0,
        instructional_method: %{code: "ENH", name: "Web Enhanced"},
        instructors: [%{email: "fperson@unm.edu", first: "Fake", last: "Person", middle_initial: "S", primary: true}],
        meeting_times: [%{building: %{code: "BLDG2", name: "Building 2"}, days: ["T", "R"], end_date: ~D[2023-06-25], end_time: ~T[14:30:00], friday: false, monday: false, room: "120", saturday: false, start_date: ~D[2023-03-01], start_time: ~T[13:00:00], sunday: false, thursday: true, tuesday: true, wednesday: false}],
        number: "002",
        part_of_term: %{code: "1", name: "Full Term"},
        semester: %{code: "202310", name: "Spring 2023"},
        status: %{code: "A", name: "Active"},
        subject: %{code: "SUBJ2", name: "Subject 2"},
        text: "",
        title: "",
        waitlist: 0,
        waitlist_max: 0,
      },
    ]

    assert Search.find_sections(params) == exptect_results
  end
end
