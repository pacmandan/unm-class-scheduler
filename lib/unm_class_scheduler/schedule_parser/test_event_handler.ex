defmodule UnmClassScheduler.ScheduleParser.TestEventHandler do
  @behaviour Saxy.Handler

  alias UnmClassScheduler.Catalog.{
    Semester,
    Campus,
    Building,
    College,
    Department,
    Subject,
    Course,
    Section,
  }

  def init_state() do
    %{
      completed: %{
        Semester => [],
        Campus => [],
        Building => [],
        College => [],
        Department => [],
        Subject => [],
        Course => [],
        Section => [],
      },
      current: %{},
    }
  end

  def handle_event(:start_document, _prolog, _state) do
    # FIXME: DO NOT USE init_state() here!
    # We want to be able to chain these together, feeding the results from
    # one file into the start of another so they just stack into the same object.

    # Figure out a good way to do this.
    {:ok, init_state()}
  end

  def handle_event(:end_document, _data, state) do
    # Return the extracted keys
    # TODO: Should we return the whole state, if we're feeding one into another?
    {:ok, state[:completed]}
  end

  # New plan (tentative):
  # - Extract:  Pull everything raw from the XML. Don't worry about duplicates.
  #             The only thing each tag needs to know about is its parents, which are in "current".
  # - Validate: Go through each extracted element and validate it. If values are missing
  #             or inconsistent, reject it.
  #             This may be the point where we want to package everything into schemas?
  # - Dedup:    Ensure only one of each unique element is taken. Instructors and buildings
  #             are going to be the worst offenders here.

  # TODO: Should we dedup _first_, before validation?
  # A lot of validation can be held directly in the schemas.
  # But the problem is that some schemas rely on others to _already_ exist.
  # Maybe we do these steps individually?
  # i.e. Extract _everything_
  # Then validate, dedup, and insert all semesters,
  # Then validate, dedup, and insert all campuses,
  # Etc.
  # In that case, the "validate" step can produce a schema, since it can use
  # previously inserted steps as the basis for validation.

  @accepted_tags %{
    "semester" => Semester,
    "campus" => Campus,
    "college" => College,
    "department" => Department,
    "subject" => Subject,
    "building" => Building,
    "course" => Course,
    "section" => Section,
    "catalog-description" => :catalog_description,
    "enrollment" => :enrollment,
    "waitlist" => :waitlist,
    "section-title" => :section_title,
    "text" => :text,
    "fees" => :fees,
    "credits" => :credits,
    "crosslists" => :crosslists,
    "start-date" => :start_date,
    "end-date" => :end_date,
    "start-time" => :start_time,
    "end-time" => :end_time,
    "day" => :day,
    "room" => :room,
  }
  @accepted_keys Map.keys(@accepted_tags)

  def handle_event(:start_element, {tag, attributes}, %{current: current, completed: completed})
    when tag in @accepted_keys do
    mattrs = Map.new(attributes)
    new_current = case @accepted_tags[tag] do
      Semester -> update_current(current, @accepted_tags[tag], mattrs)
      Campus -> update_current(current, @accepted_tags[tag], mattrs)
      College -> update_current(current, @accepted_tags[tag], mattrs)
      Department ->
        update_current(current, @accepted_tags[tag],
          mattrs |> Map.merge(%{College => Map.take(current[College], ["code"])}))
      Subject ->
        update_current(current, @accepted_tags[tag],
          mattrs |> Map.merge(%{Department => Map.take(current[Department], ["code"])}))
      Building ->
        # FIXME: Also need to update current MeetingTime in this block.
        update_current(current, @accepted_tags[tag],
          mattrs |> Map.merge(%{Campus => Map.take(current[Campus], ["code"])}))
        # |> update_current(MeetingTime, %{Building => %{code: mattrs[:code]}})
      Course ->
        update_current(current, @accepted_tags[tag],
          mattrs |> Map.merge(%{Subject => Map.take(current[Subject], ["code"])}))
      Section ->
        if current[:crosslists] do
          current
        else
          update_current(current, @accepted_tags[tag],
            mattrs |> Map.merge(%{
              Subject => Map.take(current[Subject], ["code"]),
              Course => Map.take(current[Course], ["number"]),
              Semester => Map.take(current[Semester], ["code"]),
            })
            |> rename_key("part-of-term", "part_of_term")
          )
        end
      :enrollment ->
        current
        |> update_current(Section, %{enrollment_max: mattrs["max"]})
        |> update_current(:enrollment, true)
      :waitlist ->
        current
        |> update_current(Section, %{waitlist_max: mattrs["max"]})
        |> update_current(:waitlist, true)
      _ ->
        current
    end
    new_state = %{
      current: new_current,
      completed: completed,
    }
    {:ok, new_state}
  end

  def handle_event(:end_element, tag, %{current: current, completed: completed})
    when tag in @accepted_keys do
    {new_completed, new_current} = case Map.pop(current, @accepted_tags[tag]) do
      # If this is not a tag that produces a thing, just pop it off of current.
      {true, current} -> {completed, current}
      # If this IS a new element, push it into completed.
      {new_elem, current} -> {push_completed(completed, @accepted_tags[tag], new_elem), current}
    end

    new_state = %{
      current: new_current,
      completed: new_completed,
    }
    {:ok, new_state}
  end

  def handle_event(:characters, chars, %{current: current, completed: completed}) do
    new_current = case current do
      %{Course => _course, catalog_description: true} ->
        update_current(current, Course, %{"catalog_description" => chars})
      %{Section => _section, enrollment: true} ->
        update_current(current, Section, %{"enrollment" => chars})
      %{Section => _section, waitlist: true} ->
        update_current(current, Section, %{"waitlist" => chars})
      %{Section => _section, section_title: true} ->
        update_current(current, Section, %{"title" => chars})
      %{Section => _section, fees: true} ->
        {fee, _} = Float.parse(chars)
        update_current(current, Section, %{"fees" => fee})
      %{Section => _section, credits: true} ->
        # TODO: Credits should be integer.
        # But some credits are listed as "1 TO 6".
        # Split credits into min and max, maybe?
        update_current(current, Section, %{"credits" => chars})
      %{Building => _building} ->
        update_current(current, Building, %{"name" => chars})
      _ -> current
    end
    new_state = %{
      current: new_current,
      completed: completed,
    }
    {:ok, new_state}
  end

  defp update_current(current, type, true) do
    Map.put(current, type, true)
  end

  defp update_current(current, type, updates) when is_map(updates) do
    updated = Map.merge(current[type], updates)
    Map.put(current, type, updated)
  end

  defp push_completed(completed_lists, type, new_element) do
    completed_lists
    |> Map.update!(type, fn completed -> [new_element | completed] end)
  end

  # FIXME: Move into a utils module
  defp rename_key(map, old_key, new_key) do
    with {v, m} <- Map.pop(map, old_key), do: Map.put(m, new_key, v)
  end

end
