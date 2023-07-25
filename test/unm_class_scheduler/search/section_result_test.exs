defmodule UnmClassScheduler.Search.SectionResultTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Search.SectionResult

  doctest UnmClassScheduler.Search.SectionResult

  defp setup_section(_context) do
    {:ok, section: UnmClassScheduler.SampleSection.get()}
  end

  defp forget(section, association) do
    %{section |
      association => %Ecto.Association.NotLoaded{__field__: association, __owner__: section.__struct__, __cardinality__: :one}
    }
  end

  describe "build/1" do
    setup [:setup_section]

    test "when using a fully preloaded Section", %{section: section} do
      expected_result = %{
        campus: %{code: "ABQ", name: "Albuquerque/Main"},
        college: %{code: "EN", name: "School of Engineering"},
        course: %{catalog_description: "Introduction to Computer Programming is a gentle and fun introduction. Students will use a modern Integrated Development Environment to author small programs in a high level language that do interesting things.", number: "105L", title: "Intro to Computer Programming"},
        credits_max: 3,
        credits_min: 3,
        crn: "37992",
        crosslists: [%{course_number: %{catalog_description: "Introduction to Computer Programming is a gentle and fun introduction. Students will use a modern Integrated Development Environment to author small programs in a high level language that do interesting things.", number: "105L", title: "Intro to Computer Programming"}, crn: "37994", subject_code: %{code: "CS", name: "Computer Science"}}, %{course_number: %{catalog_description: "Introduction to Computer Programming is a gentle and fun introduction. Students will use a modern Integrated Development Environment to author small programs in a high level language that do interesting things.", number: "105L", title: "Intro to Computer Programming"}, crn: "37993", subject_code: %{code: "CS", name: "Computer Science"}}],
        delivery_type: %{code: "LL", name: "Combined Lecture/Lab"},
        department: %{code: "650A", name: "Computer Science"},
        enrollment: 23,
        enrollment_max: 18,
        fees: 45.0,
        instructional_method: %{code: "ENH", name: "Web Enhanced"},
        instructors: [%{email: "glue500@unm.edu", first: "Joseph", last: "Haugh", middle_initial: nil, primary: true}],
        meeting_times: [%{building: %{code: "CENT", name: "Centennial Engineering Center"}, days: ["T", "R"], end_date: ~D[2023-05-13], end_time: ~T[10:45:00], friday: false, monday: false, room: "1041", saturday: false, start_date: ~D[2023-01-16], start_time: ~T[09:30:00], sunday: false, thursday: true, tuesday: true, wednesday: false}, %{building: %{code: "SMLC", name: "Science Math Learning Center"}, days: ["W"], end_date: ~D[2023-05-13], end_time: ~T[13:45:00], friday: false, monday: false, room: "B81", saturday: false, start_date: ~D[2023-01-16], start_time: ~T[12:00:00], sunday: false, thursday: false, tuesday: false, wednesday: true}],
        number: "001",
        part_of_term: %{code: "1", name: "Full Term"},
        semester: %{code: "202310", name: "Spring 2023"},
        status: %{code: "A", name: "Active"},
        subject: %{code: "CS", name: "Computer Science"},
        text: "Hybrid course 1.5 hours taken online.",
        title: nil,
        waitlist: 0,
        waitlist_max: 0
      }
      assert SectionResult.build(section) == expected_result
    end

    test "when nothing is preloaded", %{section: section} do
      unloaded_section = section
      |> forget(:campus)
      |> forget(:semester)
      |> forget(:course)
      |> forget(:instructional_method)
      |> forget(:status)
      |> forget(:delivery_type)
      |> forget(:part_of_term)
      |> forget(:meeting_times)
      |> forget(:crosslists)
      |> forget(:instructors)
      expected_result = %{
        credits_max: 3,
        credits_min: 3,
        crn: "37992",
        enrollment: 23,
        enrollment_max: 18,
        fees: 45.0,
        number: "001",
        text: "Hybrid course 1.5 hours taken online.",
        title: nil,
        waitlist: 0,
        waitlist_max: 0,
        campus: nil,
        college: nil,
        course: nil,
        crosslists: [],
        delivery_type: nil,
        department: nil,
        instructional_method: nil,
        instructors: [],
        meeting_times: [],
        part_of_term: nil,
        semester: nil,
        status: nil,
        subject: nil,
      }
      assert SectionResult.build(unloaded_section) == expected_result
    end
  end
end
