defmodule UnmClassScheduler.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: UnmClassScheduler.Repo

  def part_of_term_factory do
    %UnmClassScheduler.Catalog.PartOfTerm{
      code: sequence(:part_of_term_code, &"#{&1}", start_at: 100),
      name: "Auto-generated Part of Term",
    }
  end

  def status_factory do
    %UnmClassScheduler.Catalog.Status{
      code: sequence(:status_code, &"#{&1}"),
      name: "Auto-generated Status",
    }
  end

  def instructional_method_factory do
    %UnmClassScheduler.Catalog.InstructionalMethod{
      code: sequence(:instructional_method_code, &"#{&1}"),
      name: "Auto-generated Instructional Method",
    }
  end

  def delivery_type_factory do
    %UnmClassScheduler.Catalog.DeliveryType{
      code: sequence(:delivery_type_code, &"#{&1}"),
      name: "Auto-generated Delivery Type",
    }
  end

  def init_static_tables do
    %{
      parts_of_term: [insert(:part_of_term, %{code: "1", name: "Full Term"})] |> factory_map(),
      statuses: [insert(:status, %{code: "A", name: "Active"})] |> factory_map(),
      instructional_methods: [insert(:instructional_method, %{code: "ENH", name: "Web Enhanced"})] |> factory_map(),
      delivery_types: [insert(:delivery_type, %{code: "LC", name: "Lecture"})] |> factory_map(),
    }
  end

  def semester_factory do
    %UnmClassScheduler.Catalog.Semester{
      code: sequence(:semester_code, &"2023#{&1 |> Integer.to_string() |> String.pad_leading(2, "0")}"),
      name: sequence(:semester_name, &"Test Semester #{&1}"),
    }
  end

  def campus_factory do
    %UnmClassScheduler.Catalog.Campus{
      code: sequence(:campus_code, &"CAM#{&1}"),
      name: sequence(:campus_name, &"Test Campus #{&1}"),
    }
  end

  def building_factory do
    %UnmClassScheduler.Catalog.Building{
      code: sequence(:building_code, &"BLDG#{&1}"),
      name: sequence(:building_name, &"Test Building #{&1}"),
    }
  end

  def building_with_campus_factory do
    struct!(
      building_factory(),
      %{
        campus: campus_factory()
      }
    )
  end

  def college_factory do
    %UnmClassScheduler.Catalog.College{
      code: sequence(:college_code, &"COL#{&1}"),
      name: sequence(:college_name, &"Test College #{&1}"),
    }
  end

  def department_factory do
    %UnmClassScheduler.Catalog.Department{
      code: sequence(:department_code, &"DEP#{&1}"),
      name: sequence(:department_name, &"Test Department #{&1}"),
    }
  end

  def department_with_college_factory do
    struct!(
      department_factory(),
      %{
        college: college_factory()
      }
    )
  end

  def subject_factory do
    %UnmClassScheduler.Catalog.Subject{
      code: sequence(:subject_code, &"SUBJ#{&1}"),
      name: sequence(:subject_name, &"Test Subject #{&1}"),
    }
  end

  def subject_with_department_factory do
    struct!(
      subject_factory(),
      %{
        department: department_factory()
      }
    )
  end

  def subject_department_college_factory do
    struct!(
      subject_factory(),
      %{
        department: department_with_college_factory()
      }
    )
  end

  def course_factory do
    %UnmClassScheduler.Catalog.Course{
      number: sequence(:course_number, &"#{&1}", start_at: 100),
      title: sequence(:course_title, &"Course #{&1}", start_at: 100),
      catalog_description: "Auto-generated Course description",
    }
  end

  def course_with_subject_factory do
    struct!(
      course_factory(),
      %{
        subject: subject_factory()
      }
    )
  end

  def course_subject_department_college_factory do
    struct!(
      course_factory(),
      %{
        subject: subject_department_college_factory()
      }
    )
  end

  def section_factory do
    %UnmClassScheduler.Catalog.Section{
      crn: sequence(:crn, &"#{&1}", start_at: 50_000),
      number: sequence(:section_number, &"#{&1 |> Integer.to_string() |> String.pad_leading(3, "0")}", start_at: 1),
      title: "",
      enrollment: 10,
      enrollment_max: 30,
      waitlist: 15,
      waitlist_max: 25,
      credits: "3",
      credits_min: 3,
      credits_max: 3,
      fees: 0.0,
      text: ""
    }
  end

  def meeting_time_factory do
    %UnmClassScheduler.Catalog.MeetingTime{
      index: 0,
      start_date: ~D[2023-03-01],
      end_date: ~D[2023-06-25],
      start_time: ~T[10:00:00],
      end_time: ~T[10:50:00],
      sunday: false,
      monday: false,
      tuesday: false,
      wednesday: false,
      thursday: false,
      friday: false,
      saturday: false,
    }
  end

  def crosslist_factory do
    %UnmClassScheduler.Catalog.Crosslist{}
  end

  def instructor_factory do
    %UnmClassScheduler.Catalog.Instructor{
      first: Faker.Person.first_name(),
      middle_initial: Faker.Util.letter(),
      last: Faker.Person.last_name(),
      email: Faker.Internet.email(),
    }
  end

  def instructor_section_factory do
    %UnmClassScheduler.Catalog.InstructorSection{
      primary: true,
    }
  end

  def factory_map(records, key_fn \\ &code_key/1) do
    records
    |> Enum.map(fn d -> {key_fn.(d), d} end)
    |> Enum.into(%{})
  end

  @spec code_key(Ecto.Schema.t()) :: String.t()
  def code_key(data), do: data.code

  def factory_default do
    %{
      parts_of_term: parts_of_term,
      statuses: statuses,
      instructional_methods: instructional_methods,
      delivery_types: delivery_types,
    } = init_static_tables()
    semesters = [
      insert(:semester, %{code: "202310", name: "Spring 2023"}),
      insert(:semester, %{code: "202360", name: "Summer 2023"})
    ] |> factory_map()

    campuses = [
      insert(:campus, %{code: "ABQ", name: "Albuquerque/Main"}),
      insert(:campus, %{code: "GA", name: "Gallup"}),
      insert(:campus, %{code: "LA", name: "Los Alamos"}),
    ] |> factory_map()

    buildings = [
      insert(:building, %{code: "BLDG1", name: "Building 1", campus: campuses["ABQ"]}),
      insert(:building, %{code: "BLDG2", name: "Building 2", campus: campuses["ABQ"]}),
      insert(:building, %{code: "BLDG3", name: "Building 3", campus: campuses["ABQ"]}),
      insert(:building, %{code: "BLDG4", name: "Building 4", campus: campuses["GA"]}),
      insert(:building, %{code: "BLDG5", name: "Building 5", campus: campuses["LA"]}),
    ] |> factory_map()

    colleges = [
      insert(:college, %{code: "COL1", name: "College 1"}),
      insert(:college, %{code: "COL2", name: "College 2"}),
    ] |> factory_map()

    departments = [
      insert(:department, %{code: "DEP1", name: "Department 1", college: colleges["COL1"]}),
      insert(:department, %{code: "DEP2", name: "Department 2", college: colleges["COL2"]}),
    ] |> factory_map()

    subjects = [
      insert(:subject, %{code: "SUBJ1", name: "Subject 1", department: departments["DEP1"]}),
      insert(:subject, %{code: "SUBJ2", name: "Subject 2", department: departments["DEP2"]}),
    ] |> factory_map()

    courses = [
      insert(:course, %{
        number: "111",
        title: "Course 1.1",
        catalog_description: "SUBJ1 111 description",
        subject: subjects["SUBJ1"],
      }),
      insert(:course, %{
        number: "112",
        title: "Course 1.2",
        catalog_description: "SUBJ1 112 description",
        subject: subjects["SUBJ1"],
      }),
      insert(:course, %{
        number: "211",
        title: "Course 2.1",
        catalog_description: "SUBJ2 211 description",
        subject: subjects["SUBJ2"],
      }),
      insert(:course, %{
        number: "212",
        title: "Course 2.2",
        catalog_description: "SUBJ2 212 description",
        subject: subjects["SUBJ2"],
      }),
      insert(:course, %{
        number: "213",
        title: "Course 2.3",
        catalog_description: "SUBJ2 213 description",
        subject: subjects["SUBJ2"],
      }),
    ] |> factory_map(fn course -> course.number end)

    instructors = [
      insert(:instructor, %{first: "John", middle_initial: "", last: "Smith", email: "jsmith@unm.edu"}),
      insert(:instructor, %{first: "Testy", middle_initial: "J", last: "McTesterson", email: "tmctesterson@unm.edu"}),
      insert(:instructor, %{first: "Fake", middle_initial: "S", last: "Person", email: "fperson@unm.edu"}),
    ] |> factory_map(fn instructor -> instructor.email end)

    sections = [
      insert(:section, %{
        crn: "50000",
        number: "001",
        course: courses["111"],
        semester: semesters["202360"],
        campus: campuses["ABQ"],
        delivery_type: delivery_types["LC"],
        status: statuses["A"],
        part_of_term: parts_of_term["1"],
        instructional_method: instructional_methods["ENH"],
        meeting_times: [
          build(:meeting_time, %{
            index: 0,
            start_date: ~D[2023-07-01],
            end_date: ~D[2023-09-01],
            start_time: ~T[10:00:00],
            end_time: ~T[10:50:00],
            monday: true,
            wednesday: true,
            friday: true,
            room: "100",
            building: buildings["BLDG1"]
          }),
        ],
      }),
      insert(:section, %{
        crn: "50001",
        number: "001",
        course: courses["112"],
        semester: semesters["202310"],
        campus: campuses["ABQ"],
        delivery_type: delivery_types["LC"],
        status: statuses["A"],
        part_of_term: parts_of_term["1"],
        instructional_method: instructional_methods["ENH"],
        meeting_times: [
          build(:meeting_time, %{
            index: 0,
            start_time: ~T[09:00:00],
            end_time: ~T[09:50:00],
            monday: true,
            wednesday: true,
            friday: true,
            room: "100",
            building: buildings["BLDG2"]
          }),
        ],
      }),
      insert(:section, %{
        crn: "50002",
        number: "001",
        course: courses["211"],
        semester: semesters["202310"],
        campus: campuses["ABQ"],
        delivery_type: delivery_types["LC"],
        status: statuses["A"],
        part_of_term: parts_of_term["1"],
        instructional_method: instructional_methods["ENH"],
        meeting_times: [
          build(:meeting_time, %{
            index: 0,
            start_time: ~T[10:00:00],
            end_time: ~T[11:30:00],
            monday: true,
            thursday: true,
            room: "150",
            building: buildings["BLDG3"]
          }),
        ],
      }),
      insert(:section, %{
        crn: "50003",
        number: "001",
        course: courses["212"],
        semester: semesters["202310"],
        campus: campuses["ABQ"],
        delivery_type: delivery_types["LC"],
        status: statuses["A"],
        part_of_term: parts_of_term["1"],
        instructional_method: instructional_methods["ENH"],
        meeting_times: [
          build(:meeting_time, %{
            index: 0,
            start_time: ~T[15:00:00],
            end_time: ~T[15:50:00],
            monday: true,
            wednesday: true,
            room: "103",
            building: buildings["BLDG1"]
          }),
        ],
      }),
      insert(:section, %{
        crn: "50004",
        number: "002",
        course: courses["212"],
        semester: semesters["202310"],
        campus: campuses["ABQ"],
        delivery_type: delivery_types["LC"],
        status: statuses["A"],
        part_of_term: parts_of_term["1"],
        instructional_method: instructional_methods["ENH"],
        meeting_times: [
          build(:meeting_time, %{
            index: 0,
            start_time: ~T[13:00:00],
            end_time: ~T[14:30:00],
            tuesday: true,
            thursday: true,
            room: "120",
            building: buildings["BLDG2"]
          }),
        ],
      }),
      insert(:section, %{
        crn: "50005",
        number: "001",
        course: courses["213"],
        semester: semesters["202310"],
        campus: campuses["GA"],
        delivery_type: delivery_types["LC"],
        status: statuses["A"],
        part_of_term: parts_of_term["1"],
        instructional_method: instructional_methods["ENH"],
        meeting_times: [
          build(:meeting_time, %{
            index: 0,
            start_time: ~T[11:00:00],
            end_time: ~T[11:50:00],
            tuesday: true,
            thursday: true,
            room: "400",
            building: buildings["BLDG4"]
          }),
          build(:meeting_time, %{
            index: 1,
            start_time: ~T[08:00:00],
            end_time: ~T[09:50:00],
            monday: true,
            room: "400",
            building: buildings["BLDG4"]
          }),
        ],
      }),
    ] |> factory_map(fn section -> section.crn end)

    _instructor_sections = [
      insert(:instructor_section, %{
        instructor: instructors["jsmith@unm.edu"],
        section: sections["50000"],
      }),
      insert(:instructor_section, %{
        instructor: instructors["tmctesterson@unm.edu"],
        section: sections["50001"],
      }),
      insert(:instructor_section, %{
        instructor: instructors["tmctesterson@unm.edu"],
        section: sections["50002"],
      }),
      insert(:instructor_section, %{
        instructor: instructors["fperson@unm.edu"],
        section: sections["50003"],
      }),
      insert(:instructor_section, %{
        instructor: instructors["fperson@unm.edu"],
        section: sections["50004"],
      }),
      insert(:instructor_section, %{
        instructor: instructors["tmctesterson@unm.edu"],
        section: sections["50005"],
      }),
      insert(:instructor_section, %{
        instructor: instructors["fperson@unm.edu"],
        section: sections["50005"],
        primary: false,
      }),
    ]
  end
end
