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

  alias UnmClassScheduler.Catalog.{
    College,
    Campus,
    Department,
    Subject,
  }

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
        buildings: %{},
        colleges: %{},
        departments: %{},
        subjects: %{},
        courses: %{},
        sections: %{},
        meeting_times: [],
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
    # TODO: Keep this, since we might want to eventually use the "pubdate" attribute.
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
      College => %{code: tags[:college]}
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
      Department => %{code: tags[:department]}
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
      Subject => %{code: tags[:subject]}
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

  ##
  # <meeting-time>
  ##
  def handle_event(:start_element, {"meeting-time", _attributes}, %{current_tags: tags, extracted: ex}) do
    new_state = %{
      current_tags: add_current_tag(tags, :meeting_time, true),
      extracted: ex,
      # Meeting times don't have a defined "code" we can use as a key.
      # Build it as a separate item that can be appended to a list once we
      # reach the end of the tag.
      current_meeting_time: new_meeting_time(tags[:section], tags[:campus]),
    }
    {:ok, new_state}
  end

  ##
  # </meeting-time>
  ##
  def handle_event(:end_element, "meeting-time", %{current_tags: tags, extracted: ex, current_meeting_time: mt}) do
    new_state = %{
      current_tags: delete_current_tag(tags, :meeting_time),
      extracted: put_in(ex, [:meeting_times], [mt | ex[:meeting_times]]),
    }
    {:ok, new_state}
  end

  ##
  # <bldg>
  ##
  def handle_event(:start_element, {"bldg", attributes}, %{current_tags: tags, extracted: ex, current_meeting_time: mt}) do
    mattrs = Map.new(attributes)
    |> Map.merge(%{
      Campus => %{code: tags[:campus]}
    })

    new_extracted = if mattrs["code"] == "" do
      # Some meeting times have no building listed.
      # I think these are just "closed" but not actually closed?
      # Or maybe it has something to do with it being the current semester?
      # All of the ones I found with this case had "enrollment: 0",
      # and max enrollment > 0. Which is weird.

      # In this case, just skip it?
      ex
    else
      put_in(ex, [:buildings, "#{tags[:campus]}__#{mattrs["code"]}"], mattrs)
    end
    new_state = %{
      current_tags: add_current_tag(tags, :building, mattrs["code"]),
      extracted: new_extracted,
      # We also need to attach this building to the current meeting time.
      current_meeting_time: mt |> Map.merge(%{
        # In this case, it's fine if the building code is "".
        building: %{code: mattrs["code"], campus: tags[:campus]}
      })
    }
    {:ok, new_state}
  end

  ##
  # </bldg>
  ##
  def handle_event(:end_element, "bldg", %{current_tags: tags} = state) do
    {:ok, put_in(state, [:current_tags], delete_current_tag(tags, :building))}
  end

  # Simple tags with no attributes and no additional processing at start or end.
  # (These usually contain text that the :characters event captures.)
  %{
    section_title: "section-title",
    text: "text",
    fees: "fees",
    credits: "credits",
    crosslists: "crosslists",
    start_date: "start-date",
    end_date: "end-date",
    start_time: "start-time",
    end_time: "end-time",
    day: "day",
    room: "room",
    catalog_description: "catalog-description"
  }
  |> Enum.each(fn {key, element_name} ->
    def handle_event(:start_element, {unquote(element_name), _attributes}, %{current_tags: tags} = state) do
      {:ok, put_in(state, [:current_tags], add_current_tag(tags, unquote(key), true))}
    end

    def handle_event(:end_element, unquote(element_name), %{current_tags: tags} = state) do
      {:ok, put_in(state, [:current_tags], delete_current_tag(tags, unquote(key)))}
    end
  end)

  # TODO: Maybe we do this for all the :end_element events too?
  # Since most of them are identical?

  # Or we can loop these into the default handler?
  # We'd need to either figure out how to translate "string-hyphenated"
  # keys to :atomic_underscore keys, or just live with string keys.
  # (Meaning we correct the Updater module too.)

  # Default element handlers
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
      %{building: building_code, campus: campus_code} ->
        put_in(ex, [:buildings, "#{campus_code}__#{building_code}", "name"], chars)
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

  defp new_meeting_time(section_crn, campus_code) do
    %{
      campus: %{code: campus_code},
      section: %{crn: section_crn},
      sunday: false,
      monday: false,
      tuesday: false,
      wednesday: false,
      thursday: false,
      friday: false,
      saturday: false,
    }
  end
end
