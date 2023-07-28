alias UnmClassScheduler.Catalog.Semester
alias UnmClassScheduler.Catalog.Campus
alias UnmClassScheduler.Catalog.Building
alias UnmClassScheduler.Catalog.College
alias UnmClassScheduler.Catalog.Department
alias UnmClassScheduler.Catalog.Subject
alias UnmClassScheduler.Catalog.Course
alias UnmClassScheduler.Catalog.Section
alias UnmClassScheduler.Catalog.MeetingTime
alias UnmClassScheduler.Catalog.Instructor
alias UnmClassScheduler.Catalog.InstructorSection
alias UnmClassScheduler.Catalog.PartOfTerm
alias UnmClassScheduler.Catalog.DeliveryType
alias UnmClassScheduler.Catalog.Status
alias UnmClassScheduler.Catalog.InstructionalMethod
alias UnmClassScheduler.Fixtures

IO.puts "Seeding test database..."

parts_of_term = [
  %PartOfTerm{code: "1", name: "Full Term"},
] |> Fixtures.build()

statuses = [
  %Status{code: "A", name: "Active"},
] |> Fixtures.build()

instructional_methods = [
  %InstructionalMethod{code: "ENH", name: "Web Enhanced"},
] |> Fixtures.build()

delivery_types = [
  %DeliveryType{code: "LC", name: "Lecture"}
] |> Fixtures.build()

semesters = [
  %Semester{code: "202310", name: "Spring 2023"},
  %Semester{code: "202360", name: "Summer 2023"},
] |> Fixtures.build()

campuses = [
  %Campus{code: "ABQ", name: "Albuqueque/Main"},
  %Campus{code: "GA", name: "Gallup"},
  %Campus{code: "LA", name: "Los Alamos"},
] |> Fixtures.build()

buildings = [
  %Building{code: "BLDG1", name: "Building 1", campus: campuses["ABQ"]},
  %Building{code: "BLDG2", name: "Building 2", campus: campuses["ABQ"]},
  %Building{code: "BLDG3", name: "Building 3", campus: campuses["ABQ"]},
  %Building{code: "BLDG4", name: "Building 4", campus: campuses["GA"]},
  %Building{code: "BLDG5", name: "Building 5", campus: campuses["LA"]},
] |> Fixtures.build()

colleges = [
  %College{code: "COL1", name: "College 1"},
  %College{code: "COL2", name: "College 2"},
] |> Fixtures.build()

departments = [
  %Department{code: "DEP1", name: "Department 1", college: colleges["COL1"]},
  %Department{code: "DEP2", name: "Department 2", college: colleges["COL2"]},
] |> Fixtures.build()

subjects = [
  %Subject{code: "SUBJ1", name: "Subject 1", department: departments["DEP1"]},
  %Subject{code: "SUBJ2", name: "Subject 2", department: departments["DEP2"]},
] |> Fixtures.build()

courses = [
  %Course{
    number: "111",
    title: "Course 1.1",
    catalog_description: "SUBJ1 111 description",
    subject: subjects["SUBJ1"],
  },
  %Course{
    number: "112",
    title: "Course 1.2",
    catalog_description: "SUBJ1 112 description",
    subject: subjects["SUBJ1"],
  },
  %Course{
    number: "211",
    title: "Course 2.1",
    catalog_description: "SUBJ2 211 description",
    subject: subjects["SUBJ2"],
  },
  %Course{
    number: "212",
    title: "Course 2.2",
    catalog_description: "SUBJ2 212 description",
    subject: subjects["SUBJ2"],
  },
  %Course{
    number: "213",
    title: "Course 2.3",
    catalog_description: "SUBJ2 213 description",
    subject: subjects["SUBJ2"],
  },
] |> Fixtures.build(fn course -> course.number end)

instructors = [
  %Instructor{first: "John", middle_initial: "", last: "Smith", email: "jsmith@unm.edu"},
  %Instructor{first: "Testy", middle_initial: "J", last: "McTesterson", email: "tmctesterson@unm.edu"},
  %Instructor{first: "Fake", middle_initial: "S", last: "Person", email: "fperson@unm.edu"},
] |> Fixtures.build(fn instructor -> instructor.email end)

# TODO: Finish filling out sections - params, times
sections = [
  %Section{
    crn: "50000",
    number: "001",
    title: "",
    enrollment: 0,
    enrollment_max: 0,
    waitlist: 0,
    waitlist_max: 0,
    credits: "3",
    credits_min: 3,
    credits_max: 3,
    fees: 0.0,
    text: "",
    course: courses["111"],
    semester: semesters["202360"],
    campus: campuses["ABQ"],
    delivery_type: delivery_types["LC"],
    status: statuses["A"],
    part_of_term: parts_of_term["1"],
    instructional_method: instructional_methods["ENH"],
    meeting_times: [
      %MeetingTime{
        index: 0,
        start_date: ~D[2023-07-01],
        end_date: ~D[2023-09-01],
        start_time: ~T[10:00:00],
        end_time: ~T[10:50:00],
        sunday: false,
        monday: true,
        tuesday: false,
        wednesday: true,
        thursday: false,
        friday: true,
        saturday: false,
        room: "100",
        building: buildings["BLDG1"]
      },
    ],
  },
  %Section{
    crn: "50001",
    number: "001",
    title: "",
    enrollment: 0,
    enrollment_max: 0,
    waitlist: 0,
    waitlist_max: 0,
    credits: "3",
    credits_min: 3,
    credits_max: 3,
    fees: 0.0,
    text: "",
    course: courses["112"],
    semester: semesters["202310"],
    campus: campuses["ABQ"],
    delivery_type: delivery_types["LC"],
    status: statuses["A"],
    part_of_term: parts_of_term["1"],
    instructional_method: instructional_methods["ENH"],
    meeting_times: [
      %MeetingTime{
        index: 0,
        start_date: ~D[2023-03-01],
        end_date: ~D[2023-06-25],
        start_time: ~T[09:00:00],
        end_time: ~T[09:50:00],
        sunday: false,
        monday: true,
        tuesday: false,
        wednesday: true,
        thursday: false,
        friday: true,
        saturday: false,
        room: "100",
        building: buildings["BLDG2"]
      },
    ],
  },
  %Section{
    crn: "50002",
    number: "001",
    title: "",
    enrollment: 0,
    enrollment_max: 0,
    waitlist: 0,
    waitlist_max: 0,
    credits: "3",
    credits_min: 3,
    credits_max: 3,
    fees: 0.0,
    text: "",
    course: courses["211"],
    semester: semesters["202310"],
    campus: campuses["ABQ"],
    delivery_type: delivery_types["LC"],
    status: statuses["A"],
    part_of_term: parts_of_term["1"],
    instructional_method: instructional_methods["ENH"],
    meeting_times: [
      %MeetingTime{
        index: 0,
        start_date: ~D[2023-03-01],
        end_date: ~D[2023-06-25],
        start_time: ~T[10:00:00],
        end_time: ~T[11:30:00],
        sunday: false,
        monday: true,
        tuesday: false,
        wednesday: false,
        thursday: true,
        friday: false,
        saturday: false,
        room: "150",
        building: buildings["BLDG3"]
      },
    ],
  },
  %Section{
    crn: "50003",
    number: "001",
    title: "",
    enrollment: 0,
    enrollment_max: 0,
    waitlist: 0,
    waitlist_max: 0,
    credits: "3",
    credits_min: 3,
    credits_max: 3,
    fees: 0.0,
    text: "",
    course: courses["212"],
    semester: semesters["202310"],
    campus: campuses["ABQ"],
    delivery_type: delivery_types["LC"],
    status: statuses["A"],
    part_of_term: parts_of_term["1"],
    instructional_method: instructional_methods["ENH"],
    meeting_times: [
      %MeetingTime{
        index: 0,
        start_date: ~D[2023-03-01],
        end_date: ~D[2023-06-25],
        start_time: ~T[15:00:00],
        end_time: ~T[15:50:00],
        sunday: false,
        monday: true,
        tuesday: false,
        wednesday: true,
        thursday: false,
        friday: false,
        saturday: false,
        room: "103",
        building: buildings["BLDG1"]
      },
    ],
  },
  %Section{
    crn: "50004",
    number: "002",
    title: "",
    enrollment: 0,
    enrollment_max: 0,
    waitlist: 0,
    waitlist_max: 0,
    credits: "3",
    credits_min: 3,
    credits_max: 3,
    fees: 0.0,
    text: "",
    course: courses["212"],
    semester: semesters["202310"],
    campus: campuses["ABQ"],
    delivery_type: delivery_types["LC"],
    status: statuses["A"],
    part_of_term: parts_of_term["1"],
    instructional_method: instructional_methods["ENH"],
    meeting_times: [
      %MeetingTime{
        index: 0,
        start_date: ~D[2023-03-01],
        end_date: ~D[2023-06-25],
        start_time: ~T[13:00:00],
        end_time: ~T[14:30:00],
        sunday: false,
        monday: false,
        tuesday: true,
        wednesday: false,
        thursday: true,
        friday: false,
        saturday: false,
        room: "120",
        building: buildings["BLDG2"]
      },
    ],
  },
  %Section{
    crn: "50005",
    number: "001",
    title: "",
    enrollment: 0,
    enrollment_max: 0,
    waitlist: 0,
    waitlist_max: 0,
    credits: "3",
    credits_min: 3,
    credits_max: 3,
    fees: 0.0,
    text: "",
    course: courses["213"],
    semester: semesters["202310"],
    campus: campuses["GA"],
    delivery_type: delivery_types["LC"],
    status: statuses["A"],
    part_of_term: parts_of_term["1"],
    instructional_method: instructional_methods["ENH"],
    meeting_times: [
      %MeetingTime{
        index: 0,
        start_date: ~D[2023-03-01],
        end_date: ~D[2023-06-25],
        start_time: ~T[11:00:00],
        end_time: ~T[11:50:00],
        sunday: false,
        monday: false,
        tuesday: true,
        wednesday: false,
        thursday: true,
        friday: false,
        saturday: false,
        room: "400",
        building: buildings["BLDG4"]
      },
      %MeetingTime{
        index: 1,
        start_date: ~D[2023-03-01],
        end_date: ~D[2023-06-25],
        start_time: ~T[08:00:00],
        end_time: ~T[09:50:00],
        sunday: false,
        monday: true,
        tuesday: false,
        wednesday: false,
        thursday: false,
        friday: false,
        saturday: false,
        room: "400",
        building: buildings["BLDG4"]
      },
    ],
  },
] |> Fixtures.build(fn section -> section.crn end)

_instructor_sections = [
  %InstructorSection{
    instructor: instructors["jsmith@unm.edu"],
    section: sections["50000"],
    primary: true,
  },
  %InstructorSection{
    instructor: instructors["tmctesterson@unm.edu"],
    section: sections["50001"],
    primary: true,
  },
  %InstructorSection{
    instructor: instructors["tmctesterson@unm.edu"],
    section: sections["50002"],
    primary: true,
  },
  %InstructorSection{
    instructor: instructors["fperson@unm.edu"],
    section: sections["50003"],
    primary: true,
  },
  %InstructorSection{
    instructor: instructors["fperson@unm.edu"],
    section: sections["50004"],
    primary: true,
  },
  %InstructorSection{
    instructor: instructors["tmctesterson@unm.edu"],
    section: sections["50005"],
    primary: true,
  },
  %InstructorSection{
    instructor: instructors["fperson@unm.edu"],
    section: sections["50005"],
    primary: false,
  },
] |> Fixtures.build_no_key()
