defmodule UnmClassScheduler.Search.SectionResultTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Search.SectionResult

  doctest UnmClassScheduler.Search.SectionResult

  test "when using a fully preloaded Section" do
    section = %UnmClassScheduler.Catalog.Section{
      uuid: "0a550e9b-cdec-47b6-b4a2-ae1dff14abb5",
      crn: "37992",
      number: "001",
      title: nil,
      enrollment: 23,
      enrollment_max: 18,
      waitlist: 0,
      waitlist_max: 0,
      credits: "3",
      credits_min: 3,
      credits_max: 3,
      fees: 45.0,
      text: "Hybrid course 1.5 hours taken online.",
      part_of_term_uuid: "8316ea0e-a1a8-4d7f-8714-db7763c472d4",
      part_of_term: %UnmClassScheduler.Catalog.PartOfTerm{
        uuid: "8316ea0e-a1a8-4d7f-8714-db7763c472d4",
        code: "1",
        name: "Full Term",
        inserted_at: ~N[2023-07-23 16:59:27],
        updated_at: ~N[2023-07-23 16:59:27]
      },
      status_uuid: "ac36385e-de71-40dd-a4c8-0caa565eb975",
      status: %UnmClassScheduler.Catalog.Status{
        uuid: "ac36385e-de71-40dd-a4c8-0caa565eb975",
        code: "A",
        name: "Active",
        inserted_at: ~N[2023-07-23 16:59:27],
        updated_at: ~N[2023-07-23 16:59:27]
      },
      delivery_type_uuid: "0ea935cc-d256-4a71-9554-67bccce031db",
      delivery_type: %UnmClassScheduler.Catalog.DeliveryType{
        uuid: "0ea935cc-d256-4a71-9554-67bccce031db",
        code: "LL",
        name: "Combined Lecture/Lab",
        inserted_at: ~N[2023-07-23 16:59:27],
        updated_at: ~N[2023-07-23 16:59:27]
      },
      instructional_method_uuid: "160ddf39-b077-4612-bd6f-a6420323d260",
      instructional_method: %UnmClassScheduler.Catalog.InstructionalMethod{
        uuid: "160ddf39-b077-4612-bd6f-a6420323d260",
        code: "ENH",
        name: "Web Enhanced",
        inserted_at: ~N[2023-07-23 16:59:27],
        updated_at: ~N[2023-07-23 16:59:27]
      },
      semester_uuid: "e146471f-6db2-4ef0-acc6-cd7046a0cdaf",
      semester: %UnmClassScheduler.Catalog.Semester{
        uuid: "e146471f-6db2-4ef0-acc6-cd7046a0cdaf",
        code: "202310",
        name: "Spring 2023",
        inserted_at: ~N[2023-07-23 16:59:33],
        updated_at: ~N[2023-07-23 16:59:33]
      },
      course_uuid: "f49c6406-7be9-4ec7-bf62-05fd87f1246d",
      course: %UnmClassScheduler.Catalog.Course{
        uuid: "f49c6406-7be9-4ec7-bf62-05fd87f1246d",
        number: "105L",
        title: "Intro to Computer Programming",
        catalog_description: "Introduction to Computer Programming is a gentle and fun introduction. Students will use a modern Integrated Development Environment to author small programs in a high level language that do interesting things.",
        subject_uuid: "bf8d3e42-d850-4510-a355-ebde94c4df31",
        subject: %UnmClassScheduler.Catalog.Subject{
          uuid: "bf8d3e42-d850-4510-a355-ebde94c4df31",
          code: "CS",
          name: "Computer Science",
          department_uuid: "647f68f2-b106-463e-8271-a7cafce88780",
          department: %UnmClassScheduler.Catalog.Department{
            uuid: "647f68f2-b106-463e-8271-a7cafce88780",
            code: "650A",
            name: "Computer Science",
            college_uuid: "3295af75-1527-476e-9bd0-92a2e2a7d864",
            college: %UnmClassScheduler.Catalog.College{
              uuid: "3295af75-1527-476e-9bd0-92a2e2a7d864",
              code: "EN",
              name: "School of Engineering",
              inserted_at: ~N[2023-07-23 16:59:33],
              updated_at: ~N[2023-07-23 16:59:33]
            },
            inserted_at: ~N[2023-07-23 16:59:33],
            updated_at: ~N[2023-07-23 16:59:33]
          },
          inserted_at: ~N[2023-07-23 16:59:33],
          updated_at: ~N[2023-07-23 16:59:33]
        },
        inserted_at: ~N[2023-07-23 16:59:33],
        updated_at: ~N[2023-07-23 16:59:33]
      }
      campus_uuid: "535dad98-3f1b-4dd6-b0ab-35929837e2be",
      campus: %UnmClassScheduler.Catalog.Campus{
        uuid: "535dad98-3f1b-4dd6-b0ab-35929837e2be",
        code: "ABQ",
        name: "Albuquerque/Main",
        inserted_at: ~N[2023-07-23 16:59:33],
        updated_at: ~N[2023-07-23 16:59:33]
      },
      meeting_times: [
        %UnmClassScheduler.Catalog.MeetingTime{
          uuid: "73582077-59b5-46dd-8a26-08cfa5616236",
          start_date: ~D[2023-01-16],
          end_date: ~D[2023-05-13],
          start_time: ~T[09:30:00],
          end_time: ~T[10:45:00],
          sunday: false,
          monday: false,
          tuesday: true,
          wednesday: false,
          thursday: true,
          friday: false,
          saturday: false,
          room: "1041",
          index: 1,
          building_uuid: "9cae053b-4b27-4cc9-9f43-2a1234e608fe",
          building: %UnmClassScheduler.Catalog.Building{
            uuid: "9cae053b-4b27-4cc9-9f43-2a1234e608fe",
            code: "CENT",
            name: "Centennial Engineering Center",
            campus_uuid: "535dad98-3f1b-4dd6-b0ab-35929837e2be",
            inserted_at: ~N[2023-07-23 16:59:33],
            updated_at: ~N[2023-07-23 16:59:33]
          },
          section_uuid: "0a550e9b-cdec-47b6-b4a2-ae1dff14abb5",
          inserted_at: ~N[2023-07-23 16:59:44],
          updated_at: ~N[2023-07-23 16:59:44]
        },
        %UnmClassScheduler.Catalog.MeetingTime{
          uuid: "d57f4910-4eb9-47db-b7df-100755addc1d",
          start_date: ~D[2023-01-16],
          end_date: ~D[2023-05-13],
          start_time: ~T[12:00:00],
          end_time: ~T[13:45:00],
          sunday: false,
          monday: false,
          tuesday: false,
          wednesday: true,
          thursday: false,
          friday: false,
          saturday: false,
          room: "B81",
          index: 0,
          building_uuid: "43cf0f73-52f2-4091-bc7d-40b08a62e665",
          building: %UnmClassScheduler.Catalog.Building{
            uuid: "43cf0f73-52f2-4091-bc7d-40b08a62e665",
            code: "SMLC",
            name: "Science Math Learning Center",
            campus_uuid: "535dad98-3f1b-4dd6-b0ab-35929837e2be",
            inserted_at: ~N[2023-07-23 16:59:33],
            updated_at: ~N[2023-07-23 16:59:33]
          },
          section_uuid: "0a550e9b-cdec-47b6-b4a2-ae1dff14abb5",
          inserted_at: ~N[2023-07-23 16:59:44],
          updated_at: ~N[2023-07-23 16:59:44]
        }
      ],
      crosslists: [
        %UnmClassScheduler.Catalog.Section{
          uuid: "a6b7376a-18d6-4078-bcd3-42c61984511d",
          crn: "37994",
          number: "003",
          title: nil,
          enrollment: 19,
          enrollment_max: 18,
          waitlist: 0,
          waitlist_max: 0,
          credits: "3",
          credits_min: 3,
          credits_max: 3,
          fees: 45.0,
          text: "Hybrid course 1.5 hours taken online.",
          part_of_term_uuid: "8316ea0e-a1a8-4d7f-8714-db7763c472d4",
          status_uuid: "ac36385e-de71-40dd-a4c8-0caa565eb975",
          delivery_type_uuid: "0ea935cc-d256-4a71-9554-67bccce031db",
          instructional_method_uuid: "160ddf39-b077-4612-bd6f-a6420323d260",
          semester_uuid: "e146471f-6db2-4ef0-acc6-cd7046a0cdaf",
          course_uuid: "f49c6406-7be9-4ec7-bf62-05fd87f1246d",
          course: %UnmClassScheduler.Catalog.Course{
            uuid: "f49c6406-7be9-4ec7-bf62-05fd87f1246d",
            number: "105L",
            title: "Intro to Computer Programming",
            catalog_description: "Introduction to Computer Programming is a gentle and fun introduction. Students will use a modern Integrated Development Environment to author small programs in a high level language that do interesting things.",
            subject_uuid: "bf8d3e42-d850-4510-a355-ebde94c4df31",
            subject: %UnmClassScheduler.Catalog.Subject{
              uuid: "bf8d3e42-d850-4510-a355-ebde94c4df31",
              code: "CS",
              name: "Computer Science",
              department_uuid: "647f68f2-b106-463e-8271-a7cafce88780",
              inserted_at: ~N[2023-07-23 16:59:33],
              updated_at: ~N[2023-07-23 16:59:33]
            },
            inserted_at: ~N[2023-07-23 16:59:33],
            updated_at: ~N[2023-07-23 16:59:33]
          },
          campus_uuid: "535dad98-3f1b-4dd6-b0ab-35929837e2be",
          inserted_at: ~N[2023-07-23 16:59:34],
          updated_at: ~N[2023-07-23 16:59:34]
        },
        %UnmClassScheduler.Catalog.Section{
          uuid: "62c53681-a72f-4fdd-aa3a-0664d4376988",
          crn: "37993",
          number: "002",
          title: nil,
          enrollment: 17,
          enrollment_max: 18,
          waitlist: 0,
          waitlist_max: 0,
          credits: "3",
          credits_min: 3,
          credits_max: 3,
          fees: 45.0,
          text: "Hybrid course 1.5 hours taken online.",
          part_of_term_uuid: "8316ea0e-a1a8-4d7f-8714-db7763c472d4",
          status_uuid: "ac36385e-de71-40dd-a4c8-0caa565eb975",
          delivery_type_uuid: "0ea935cc-d256-4a71-9554-67bccce031db",
          instructional_method_uuid: "160ddf39-b077-4612-bd6f-a6420323d260",
          semester_uuid: "e146471f-6db2-4ef0-acc6-cd7046a0cdaf",
          course_uuid: "f49c6406-7be9-4ec7-bf62-05fd87f1246d",
          course: %UnmClassScheduler.Catalog.Course{
            uuid: "f49c6406-7be9-4ec7-bf62-05fd87f1246d",
            number: "105L",
            title: "Intro to Computer Programming",
            catalog_description: "Introduction to Computer Programming is a gentle and fun introduction. Students will use a modern Integrated Development Environment to author small programs in a high level language that do interesting things.",
            subject_uuid: "bf8d3e42-d850-4510-a355-ebde94c4df31",
            subject: %UnmClassScheduler.Catalog.Subject{
              uuid: "bf8d3e42-d850-4510-a355-ebde94c4df31",
              code: "CS",
              name: "Computer Science",
              department_uuid: "647f68f2-b106-463e-8271-a7cafce88780",
              inserted_at: ~N[2023-07-23 16:59:33],
              updated_at: ~N[2023-07-23 16:59:33]
            },
            inserted_at: ~N[2023-07-23 16:59:33],
            updated_at: ~N[2023-07-23 16:59:33]
          },
          campus_uuid: "535dad98-3f1b-4dd6-b0ab-35929837e2be",
          inserted_at: ~N[2023-07-23 16:59:34],
          updated_at: ~N[2023-07-23 16:59:34]
        }
      ],
      instructors: [
        %UnmClassScheduler.Catalog.InstructorSection{
          uuid: "362f1101-b375-40ba-9232-aaf3fa383f8c",
          primary: true,
          section_uuid: "0a550e9b-cdec-47b6-b4a2-ae1dff14abb5",
          instructor_uuid: "415537bb-ebfc-4b20-8149-077ed2f3a39e",
          instructor: %UnmClassScheduler.Catalog.Instructor{
            uuid: "415537bb-ebfc-4b20-8149-077ed2f3a39e",
            first: "Joseph",
            last: "Haugh",
            middle_initial: nil,
            email: "glue500@unm.edu",
            inserted_at: ~N[2023-07-23 16:59:50],
            updated_at: ~N[2023-07-23 16:59:50]
          },
          inserted_at: ~N[2023-07-23 16:59:50],
          updated_at: ~N[2023-07-23 16:59:50]
        }
      ],
      inserted_at: ~N[2023-07-23 16:59:34],
      updated_at: ~N[2023-07-23 16:59:34]
    }
  end
end
