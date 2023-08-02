defmodule UnmClassScheduler.ScheduleParser.XMLExtractorTest do
    @moduledoc false
    use ExUnit.Case, async: true

    alias UnmClassScheduler.ScheduleParser.XMLExtractor
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

    doctest UnmClassScheduler.ScheduleParser.XMLExtractor

    @testfile1 "./test/support/samplexml.xml"

    test "properly extracts from 1 XML file" do
      expected_results = %{
        Semester => [%E{fields: %{code: "2023XX", name: "Test 2023"}}],
        Campus => [
          %E{fields: %{code: "ABQ", name: "Albuquerque/Main"}},
          %E{fields: %{code: "GA", name: "Gallup"}},
        ],
        Building => [
          %E{fields: %{code: "BLDG1", name: "Building 1"}, associations: %{Campus => %{code: "ABQ"}}},
          %E{fields: %{code: "BLDG2", name: "Building 2"}, associations: %{Campus => %{code: "ABQ"}}},
          %E{fields: %{code: "BLDG3", name: "Building 3"}, associations: %{Campus => %{code: "ABQ"}}},
          %E{fields: %{code: "BLDG4", name: "Building 4"}, associations: %{Campus => %{code: "GA"}}},
        ],
        College => [
          %E{fields: %{code: "COL1", name: "College 1"}},
          %E{fields: %{code: "COL2", name: "College 2"}},
        ],
        Department => [
          %E{fields: %{code: "DEP1", name: "Department 1"}, associations: %{College => %{code: "COL1"}}},
          %E{fields: %{code: "DEP2", name: "Department 2"}, associations: %{College => %{code: "COL2"}}},
        ],
        Subject => [
          %E{fields: %{code: "SUBJ1", name: "Subject 1"}, associations: %{Department => %{code: "DEP1"}}},
          %E{fields: %{code: "SUBJ2", name: "Subject 2"}, associations: %{Department => %{code: "DEP2"}}},
        ],
        Course => [
          %E{fields: %{catalog_description: "SUBJ1 111 description", number: "111", title: "Course 1.1"}, associations: %{Subject => %{code: "SUBJ1"}}},
          %E{fields: %{catalog_description: "SUBJ1 112 description", number: "112", title: "Course 1.1"}, associations: %{Subject => %{code: "SUBJ1"}}},
          %E{fields: %{catalog_description: "SUBJ1 211 description", number: "211", title: "Course 2.1"}, associations: %{Subject => %{code: "SUBJ2"}}},
          %E{fields: %{catalog_description: "SUBJ1 212 description", number: "212", title: "Course 2.2"}, associations: %{Subject => %{code: "SUBJ2"}}},
          %E{fields: %{catalog_description: "SUBJ1 213 description", number: "213", title: "Course 2.3"}, associations: %{Subject => %{code: "SUBJ2"}}},
        ],
        Section => [
          %E{fields: %{credits: "3", credits_max: 3, credits_min: 3, crn: "50000", enrollment: "3", enrollment_max: "10", fees: 50.23, num_meetings: 1, number: "001", text: "This is the section 50000 text", title: "Section 50000 title", waitlist: "15", waitlist_max: "30"}, associations: %{Campus => %{code: "ABQ"}, Course => %{number: "111"}, DeliveryType => %{code: "LC"}, InstructionalMethod => %{code: "ENH"}, PartOfTerm => %{code: "1"}, Semester => %{code: "2023XX"}, Status => %{code: "A"}, Subject => %{code: "SUBJ1"}}},
          %E{fields: %{credits: "3", credits_max: 3, credits_min: 3, crn: "50001", enrollment: "0", enrollment_max: "0", fees: 0.0, num_meetings: 1, number: "001", waitlist: "0", waitlist_max: "0"}, associations: %{Campus => %{code: "ABQ"}, Course => %{number: "112"}, DeliveryType => %{code: "LC"}, InstructionalMethod => %{code: "ENH"}, PartOfTerm => %{code: "1"}, Semester => %{code: "2023XX"}, Status => %{code: "A"}, Subject => %{code: "SUBJ1"}}},
          %E{fields: %{credits: "3", credits_max: 3, credits_min: 3, crn: "50002", enrollment: "0", enrollment_max: "0", fees: 0.0, num_meetings: 1, number: "001", waitlist: "0", waitlist_max: "0"}, associations: %{Campus => %{code: "ABQ"}, Course => %{number: "211"}, DeliveryType => %{code: "LC"}, InstructionalMethod => %{code: "ENH"}, PartOfTerm => %{code: "1"}, Semester => %{code: "2023XX"}, Status => %{code: "A"}, Subject => %{code: "SUBJ2"}}},
          %E{fields: %{credits: "3", credits_max: 3, credits_min: 3, crn: "50003", enrollment: "0", enrollment_max: "0", fees: 0.0, num_meetings: 1, number: "001", waitlist: "0", waitlist_max: "0"}, associations: %{Campus => %{code: "ABQ"}, Course => %{number: "212"}, DeliveryType => %{code: "LC"}, InstructionalMethod => %{code: "ENH"}, PartOfTerm => %{code: "1"}, Semester => %{code: "2023XX"}, Status => %{code: "A"}, Subject => %{code: "SUBJ2"}}},
          %E{fields: %{credits: "3", credits_max: 3, credits_min: 3, crn: "50004", enrollment: "0", enrollment_max: "0", fees: 0.0, num_meetings: 1, number: "002", waitlist: "0", waitlist_max: "0"}, associations: %{Campus => %{code: "ABQ"}, Course => %{number: "212"}, DeliveryType => %{code: "LC"}, InstructionalMethod => %{code: "ENH"}, PartOfTerm => %{code: "1"}, Semester => %{code: "2023XX"}, Status => %{code: "A"}, Subject => %{code: "SUBJ2"}}},
          %E{fields: %{credits: "3", credits_max: 3, credits_min: 3, crn: "50005", enrollment: "0", enrollment_max: "0", fees: 0.0, num_meetings: 2, number: "002", waitlist: "0", waitlist_max: "0"}, associations: %{Campus => %{code: "GA"}, Course => %{number: "213"}, DeliveryType => %{code: "LC"}, InstructionalMethod => %{code: "ENH"}, PartOfTerm => %{code: "1"}, Semester => %{code: "2023XX"}, Status => %{code: "A"}, Subject => %{code: "SUBJ2"}}},
        ],
        Instructor => [
          %E{fields: %{email: "jsmith@unm.edu", first: "John", last: "Smith"}},
          %E{fields: %{email: "fperson@unm.edu", first: "Fake", last: "Person", middle_initial: "M"}},
          %E{fields: %{email: "tmctesterson@unm.edu", first: "Testy", last: "McTesterson", middle_initial: "J"}},
        ],
        MeetingTime => [
          %E{fields: %{end_date: ~D[2023-05-13], end_time: ~T[10:50:00], friday: true, index: 0, monday: true, room: "100", saturday: false, start_date: ~D[2023-01-16], start_time: ~T[10:00:00], sunday: false, thursday: false, tuesday: false, wednesday: true}, associations: %{Building => %{code: "BLDG1"}, Campus => %{code: "ABQ"}, Section => %{crn: "50000"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{end_date: ~D[2023-05-13], end_time: ~T[15:50:00], friday: false, index: 0, monday: true, room: "103", saturday: false, start_date: ~D[2023-01-16], start_time: ~T[15:00:00], sunday: false, thursday: false, tuesday: false, wednesday: true}, associations: %{Building => %{code: "BLDG1"}, Campus => %{code: "ABQ"}, Section => %{crn: "50003"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{end_date: ~D[2023-05-13], end_time: ~T[09:50:00], friday: true, index: 0, monday: true, room: "100", saturday: false, start_date: ~D[2023-01-16], start_time: ~T[09:00:00], sunday: false, thursday: false, tuesday: false, wednesday: true}, associations: %{Building => %{code: "BLDG2"}, Campus => %{code: "ABQ"}, Section => %{crn: "50001"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{end_date: ~D[2023-05-13], end_time: ~T[14:30:00], friday: false, index: 0, monday: false, room: "120", saturday: false, start_date: ~D[2023-01-16], start_time: ~T[13:00:00], sunday: false, thursday: true, tuesday: true, wednesday: false}, associations: %{Building => %{code: "BLDG2"}, Campus => %{code: "ABQ"}, Section => %{crn: "50004"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{end_date: ~D[2023-05-13], end_time: ~T[11:30:00], friday: false, index: 0, monday: true, room: "150", saturday: false, start_date: ~D[2023-01-16], start_time: ~T[10:00:00], sunday: false, thursday: true, tuesday: false, wednesday: false}, associations: %{Building => %{code: "BLDG3"}, Campus => %{code: "ABQ"}, Section => %{crn: "50002"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{end_date: ~D[2023-05-13], end_time: ~T[10:30:00], friday: true, index: 1, monday: true, room: "400", saturday: false, start_date: ~D[2023-01-16], start_time: ~T[08:00:00], sunday: false, thursday: false, tuesday: false, wednesday: false}, associations: %{Building => %{code: "BLDG4"}, Campus => %{code: "GA"}, Section => %{crn: "50005"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{end_date: ~D[2023-05-13], end_time: ~T[14:30:00], friday: false, index: 0, monday: false, room: "400", saturday: true, start_date: ~D[2023-01-16], start_time: ~T[13:00:00], sunday: true, thursday: false, tuesday: false, wednesday: false}, associations: %{Building => %{code: "BLDG4"}, Campus => %{code: "GA"}, Section => %{crn: "50005"}, Semester => %{code: "2023XX"}}},
        ],
        InstructorSection => [
          %E{fields: %{primary: true}, associations: %{Instructor => %{email: "fperson@unm.edu", first: "Fake", last: "Person"}, Section => %{crn: "50004"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{primary: true}, associations: %{Instructor => %{email: "fperson@unm.edu", first: "Fake", last: "Person"}, Section => %{crn: "50005"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{primary: true}, associations: %{Instructor => %{email: "fperson@unm.edu", first: "Fake", last: "Person"}, Section => %{crn: "50003"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{primary: true}, associations: %{Instructor => %{email: "jsmith@unm.edu", first: "John", last: "Smith"}, Section => %{crn: "50000"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{primary: true}, associations: %{Instructor => %{email: "tmctesterson@unm.edu", first: "Testy", last: "McTesterson"}, Section => %{crn: "50001"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{primary: true}, associations: %{Instructor => %{email: "tmctesterson@unm.edu", first: "Testy", last: "McTesterson"}, Section => %{crn: "50002"}, Semester => %{code: "2023XX"}}},
          %E{fields: %{primary: false}, associations: %{Instructor => %{email: "tmctesterson@unm.edu", first: "Testy", last: "McTesterson"}, Section => %{crn: "50005"}, Semester => %{code: "2023XX"}}},
        ],
        Crosslist => [
          %E{fields: %{course_number: "212", subject_code: "SUBJ2"}, associations: %{Semester => %{code: "2023XX"}, :crosslist => %{crn: "50003"}, :section => %{crn: "50004"}}},
          %E{fields: %{course_number: "212", subject_code: "SUBJ2"}, associations: %{Semester => %{code: "2023XX"}, :crosslist => %{crn: "50004"}, :section => %{crn: "50003"}}},
        ],
      }
      |> Enum.map(fn {key, list} -> {key, Enum.sort(list)} end)
      |> Enum.into(%{})

      results = XMLExtractor.extract_from([@testfile1])
      |> Enum.map(fn {key, list} -> {key, Enum.sort(list)} end)
      |> Enum.into(%{})

      assert results == expected_results
    end
end
