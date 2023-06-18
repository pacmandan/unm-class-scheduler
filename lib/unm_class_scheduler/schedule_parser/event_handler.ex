defmodule UnmClassScheduler.ScheduleParser.EventHandler do
  @behaviour Saxy.Handler

  _notes = """
  Stray thoughts about goals, issues, and overall strategy. (Literally I'm just brain dumping into source code, I don't care.)

  The source XML file lists many parts of the schedule multiple times. It is organized:
  Semester > Campus > College > Department > Subject > Course > Section

  So Subjects, for instance, may be duplicated if they are taught at multiple Campuses.
  Section has Instructors, MeetingTimes, and Crosslists underneath, so every instructor is fully listed for every section they teach.
  (MeetingTimes also have Buildings listed.)

  However, each Department only has one College, each Subject only has one Department, each Course only has one Subject, and each Section only has one Course.

  Also, each Building can only ever be on one Campus. So it might be good to invert this organization.

  So it's more like:
  Semester ------------------------------------\          /----(many) Instructors
  (Campus?) ------------------------------------> Section <--> Crosslists
  College -> Department -> Subject -> Course --/         \----(many) MeetingTimes -> Building -> Campus

  There's also things like Statuses and DeliveryTypes I'm leaving out, but this is complicated enough for now.
  Those are static types that likely aren't going to change much, we can maybe add all of those once at the start and not worry about it?

  I want to insert/update these all at the same time in a single transaction, so as not to have any possible race conditions
  with existing connections, ending up with inconsistent data. So all models need to be extracted and de-duped before insertion.

  Additionally, anything NOT in the XML must be deleted from the database.

  To that end, no models will be created here. Only params will be extracted.
  These will be saved to state so they can be referenced if need be by other tags.
  Each element handler will create a new listing in the corresponding model mapping.
  Keys will be IDs used by the model so we can quickly find if a duplicate exists.

  %{
    semesters: %{"semester_code" => %{code: "semester_code", name: "semester_name"}, ...}
    campuses: %{"campus_code" => %{}, "campus_code_2" => %{}, ...}
    ...
  }

  For things that reference other things, we can add the referenced code, since that will be available from the current
  element list we're on. (Which is obviously going to be saved to and popped from state as we go.)
  %{
    ...
    colleges: %{"college_code" => %{},...}
    departments: %{"department_code" => %{code: "department_code", name: "Department", college: [code: "college_code"]}}
  }

  I've tested this with a Keyword list, I'm not sure if a map is acceptable for the next part, but if so then just imagine it's a map.

  Once we get to the insert step (in another module), we can insert these in order, and use the referenced values to search
  in the DB for the appropriate PK to reference:

  college = repo.get_by!(College, department_attrs[:college])

  Sections are going to be the tricky ones, as each will have multiple MeetingTimes (which will have a Building) and multiple Instructors,
  neither of which have a truely unique ID to detect duplicates.

  For Instructors, we can probably get away with using email, but I don't know for certain if every instructor has an email.
  (I guess we'll set up an error to detect it during testing and go from there if need be.)

  For MeetingTimes, we don't need a many-to-many like we do with Instructors - each one can just be unique and reference
  the section CRN directly, and we can figure out if a new one needs to be created or an existing one updated during the insert to DB step.

  Either way, the section will reference Instructors and MeetingTimes like this:
  %{
    sections: %{
      "section_crn": %{
        crn: "section_crn",
        ...
        instructors: [
          [first: "Testy", last: "McTesterson", email: "tmctesterson@unm.edu", ...],
        ...]
        meeting_times: [
          [start_date: "...", end_date: "...", ...],
        ...]
      }
    }
  }

  Effectively just listing each of them in full, so the db inserter can search for them by every element.

  instructors = Enum.map(section_attrs[:instructors], fn instructor_attrs ->
    repo.get_by!(Instructor, instructor_attrs)
  end)
  # (Yes, I know there's a better way to get everything more directly, I'm just brain-dumping right now.)

  This is probably very inefficient, and I'm still working on a better solution. This also doesn't cover the situation
  where we want to UPDATE a meeting time or instructor instead of fully replacing them. Though I'm not 100% sure if we actually want
  to do things that way - it may be more efficient to just fully replace them if one field changes given the nature of the
  way we're updating the database...

  And we haven't even gotten into one of the bigger issues surrounding deletions, since I'd like to delete anything
  that ISN'T in the current XML files.
  I think the best way to handle those is to just keep a record of everything we've inserted/updated, and anything
  not on that list we just delete?

  Anyway, thank you for coming to my TED Talk.
  """

  # TODO: This part should probably be moved.
  # Initial state should be passed into the parser, so
  # we should just have a function to call that runs the parser
  # with proper initial state.
  def init_state() do
    %{
      current_tags: %{},
      extracted: %{
        semesters: %{},
        campuses: %{},
        colleges: %{},
        departments: %{},
        subjects: %{},
        courses: %{},
        sections: %{},
      },
    }
  end

  def handle_event(:start_document, _prolog, _state) do
    {:ok, init_state()}
  end

  def handle_event(:end_document, _data, state) do
    # Return the extracted keys
    {:ok, state[:extracted]}
  end

  ##
  # <unmschedule>
  ##
  def handle_event(:start_element, {"unmschedule", _attributes}, state) do
    {:ok, state}
  end

  ##
  # </unmschedule>
  ##
  def handle_event(:end_element, "unmschedule", state) do
    {:ok, state}
  end

  ##
  # <semester>
  ##
  def handle_event(:start_element, {"semester", attributes}, %{current_tags: tags, extracted: ex}) do
    mattrs = Map.new(attributes)
    new_state = %{
      current_tags: add_current_tag(tags, :semester, mattrs["code"]),
      extracted: put_in(ex, [:semesters, mattrs["code"]], mattrs)
    }
    {:ok, new_state}
  end

  ##
  # </semester>
  ##
  def handle_event(:end_element, "semester", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :semester))}
  end

  ##
  # <campus>
  ##
  def handle_event(:start_element, {"campus", attributes}, %{current_tags: tags, extracted: ex}) do
    mattrs = Map.new(attributes)
    new_state = %{
      current_tags: add_current_tag(tags, :campus, mattrs["code"]),
      extracted: put_in(ex, [:campuses, mattrs["code"]], mattrs)
    }
    {:ok, new_state}
  end

  ##
  # <campus>
  ##
  def handle_event(:end_element, "campus", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :campus))}
  end

  ##
  # <college>
  ##
  def handle_event(:start_element, {"college", attributes}, %{current_tags: tags, extracted: ex}) do
    mattrs = Map.new(attributes)
    new_state = %{
      current_tags: add_current_tag(tags, :college, mattrs["code"]),
      extracted: put_in(ex, [:colleges, mattrs["code"]], mattrs)
    }
    {:ok, new_state}
  end

  ##
  # </college>
  ##
  def handle_event(:end_element, "college", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :college))}
  end

  ##
  # <department>
  ##
  def handle_event(:start_element, {"department", attributes}, %{current_tags: tags, extracted: ex}) do
    mattrs = Map.new(attributes)
    |> Map.merge(%{
      college: %{code: tags[:college]}
    })

    new_state = %{
      current_tags: add_current_tag(tags, :department, mattrs["code"]),
      extracted: put_in(ex, [:departments, mattrs["code"]], mattrs)
    }
    {:ok, new_state}
  end

  ##
  # </department>
  ##
  def handle_event(:end_element, "department", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :department))}
  end

  ##
  # <subject>
  ##
  def handle_event(:start_element, {"subject", attributes}, %{current_tags: tags, extracted: ex}) do
    mattrs = Map.new(attributes)
    |> Map.merge(%{
      department: %{code: tags[:department]}
    })

    new_state = %{
      current_tags: add_current_tag(tags, :subject, mattrs["code"]),
      extracted: put_in(ex, [:subjects, mattrs["code"]], mattrs)
    }
    {:ok, new_state}
  end

  ##
  # </subject>
  ##
  def handle_event(:end_element, "subject", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :subject))}
  end


  ##
  # <course>
  ##
  def handle_event(:start_element, {"course", attributes}, %{current_tags: tags, extracted: ex}) do
    mattrs = Map.new(attributes)
    |> Map.merge(%{
      subject: %{code: tags[:subject]}
    })

    course_key = build_course_key(tags[:subject], mattrs["number"])

    new_state = %{
      current_tags: add_current_tag(tags, :course, course_key),
      extracted: put_in(ex, [:courses, course_key], mattrs)
    }
    {:ok, new_state}
  end

  ##
  # </course>
  ##
  def handle_event(:end_element, "course", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :course))}
  end

  ##
  # <catalog-description>
  ##
  def handle_event(:start_element, {"catalog-description", _attributes}, %{current_tags: tags, extracted: ex}) do
    new_state = %{
      current_tags: add_current_tag(tags, :catalog_description, true),
      extracted: ex
    }
    {:ok, new_state}
  end

  ##
  # </catalog-description>
  ##
  def handle_event(:end_element, "catalog-description", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :catalog_description))}
  end

  ##
  # <section>
  ##
  def handle_event(:start_element, {"section", attributes}, %{current_tags: tags, extracted: ex}) do
    if tags[:crosslists] do
      # TODO: Add crosslist handling
      {:ok, %{current_tags: tags, extracted: ex}}
    else
      [subject_code, course_number] = split_course_key(tags[:course])
      mattrs = Map.new(attributes)
      |> Map.merge(%{
        subject: %{code: subject_code},
        course: %{number: course_number},
        semester: %{code: tags[:semester]}
      }) |> rename_key("part-of-term", "part_of_term")

      new_state = %{
        current_tags: add_current_tag(tags, :section, mattrs["crn"]),
        extracted: put_in(ex, [:sections, mattrs["crn"]], mattrs)
      }
      {:ok, new_state}
    end
  end

  ##
  # </section>
  ##
  def handle_event(:end_element, "section", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :section))}
  end

  ##
  # <enrollment>
  ##
  def handle_event(:start_element, {"enrollment", %{max: max}}, %{current_tags: tags, extracted: ex}) do
    new_state = %{
      current_tags: add_current_tag(tags, :enrollment, true),
      extracted: put_in(ex, [:sections, tags[:section], :enrollment_max], max)
    }
    {:ok, new_state}
  end

  ##
  # </enrollment>
  ##
  def handle_event(:end_element, "enrollment", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :enrollment))}
  end

  ##
  # <waitlist>
  ##
  def handle_event(:start_element, {"waitlist", %{max: max}}, %{current_tags: tags, extracted: ex}) do
    new_state = %{
      current_tags: add_current_tag(tags, :waitlist, true),
      extracted: put_in(ex, [:sections, tags[:section], :waitlist_max], max)
    }
    {:ok, new_state}
  end

  ##
  # </waitlist>
  ##
  def handle_event(:end_element, "waitlist", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :waitlist))}
  end

  # TODO: Unify these since they're all the same function.

  ##
  # <section-title>
  ##
  def handle_event(:start_element, {"section-title", _attributes}, %{current_tags: tags, extracted: ex}) do
    new_state = %{
      current_tags: add_current_tag(tags, :section_title, true),
      extracted: ex
    }
    {:ok, new_state}
  end

  ##
  # </section-title>
  ##
  def handle_event(:end_element, "section-title", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :section_title))}
  end

  ##
  # <text>
  ##
  def handle_event(:start_element, {"text", _attributes}, %{current_tags: tags, extracted: ex}) do
    new_state = %{
      current_tags: add_current_tag(tags, :text, true),
      extracted: ex
    }
    {:ok, new_state}
  end

  ##
  # </text>
  ##
  def handle_event(:end_element, "text", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :text))}
  end

  ##
  # <fees>
  ##
  def handle_event(:start_element, {"fees", _attributes}, %{current_tags: tags, extracted: ex}) do
    new_state = %{
      current_tags: add_current_tag(tags, :fees, true),
      extracted: ex
    }
    {:ok, new_state}
  end

  ##
  # </fees>
  ##
  def handle_event(:end_element, "fees", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :fees))}
  end

  ##
  # <credits>
  ##
  def handle_event(:start_element, {"credits", _attributes}, %{current_tags: tags, extracted: ex}) do
    new_state = %{
      current_tags: add_current_tag(tags, :credits, true),
      extracted: ex
    }
    {:ok, new_state}
  end

  ##
  # </credits>
  ##
  def handle_event(:end_element, "credits", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :credits))}
  end

  ##
  # <crosslists>
  ##
  def handle_event(:start_element, {"crosslists", _attributes}, %{current_tags: tags, extracted: ex}) do
    new_state = %{
      current_tags: add_current_tag(tags, :crosslists, true),
      extracted: ex
    }
    {:ok, new_state}
  end

  ##
  # </crosslists>
  ##
  def handle_event(:end_element, "crosslists", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :crosslists))}
  end


  # Default element handlers
  # Need more nuance here - internal elements to the ignored ones could mess up context/state
  # Perhaps an "ignore" flag in the state when we hit something?
  def handle_event(:start_element, {_name, _attributes}, state) do
    {:ok, state}
  end

  def handle_event(:end_element, _name, state) do
    {:ok, state}
  end

  def handle_event(:characters, chars, %{current_tags: tags, extracted: ex}) do
    # Need to use state for context of where we are in the file - only text from between tags is passed here.
    new_ex = case tags do
      # Catalog description for a course
      %{course: course_key, catalog_description: true} ->
        put_in(ex, [:courses, course_key, "catalog_description"], chars)
      %{section: crn, enrollment: true} ->
        put_in(ex, [:sections, crn, "enrollment"], chars)
      %{section: crn, waitlist: true} ->
        put_in(ex, [:sections, crn, "waitlist"], chars)
      %{section: crn, section_title: true} ->
        put_in(ex, [:sections, crn, "title"], chars)
      %{section: crn, text: true} ->
        put_in(ex, [:sections, crn, "text"], chars)
      %{section: crn, fees: true} ->
        {fee, _} = Float.parse(chars)
        put_in(ex, [:sections, crn, "fees"], fee)
      %{section: crn, credits: true} ->
        # TODO: Credits should be integer.
        # But some credits are listed as "1 TO 6".
        # Split credits into min and max, maybe?
        put_in(ex, [:sections, crn, "credits"], chars)
      # Unknown state, return ex as is.
      _ -> ex
    end
    {:ok, %{current_tags: tags, extracted: new_ex}}
  end

  defp add_current_tag(tags, tag_type, tag_key) do
    tags
    |> Map.put(tag_type, tag_key)
  end

  defp delete_current_tag(tags, tag_type) do
    tags
    |> Map.delete(tag_type)
  end

  defp build_course_key(subject_code, course_number) do
    "#{subject_code}__#{course_number}"
  end

  defp split_course_key(key) do
    String.split(key, "__", parts: 2)
  end

  # FIXME: Move into a utils module
  defp rename_key(map, old_key, new_key) do
    with {v, m} <- Map.pop(map, old_key), do: Map.put(m, new_key, v)
  end
end
