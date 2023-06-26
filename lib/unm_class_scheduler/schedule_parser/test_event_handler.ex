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

  def handle_event(:end_document, _data, %{completed: completed}) do
    # Return the extracted keys
    new_completed = %{
      Semester => (completed[Semester] |> Enum.uniq_by((&(&1["code"])))),
      Campus => (completed[Campus] |> Enum.uniq_by((&(&1["code"])))),
      Building => completed[Building]
        # TODO: Try a comprehension here
        |> Enum.reject((&(&1["code"] == "")))
        |> Enum.uniq_by((&({&1["code"], &1[Campus]["code"]}))),
      College => completed[College] |> Enum.uniq_by((&(&1["code"]))),
      Department => completed[Department] |> Enum.uniq_by((&(&1["code"]))),
      Subject => completed[Subject] |> Enum.uniq_by((&(&1["code"]))),
      Course => completed[Course] |> Enum.uniq_by((&({&1["number"], &1[Subject]["code"]}))),
      Section => completed[Section] |> Enum.uniq_by((&({&1["crn"], &1[Semester]["code"]}))),
    }
    {:ok, new_completed}
  end

  @doc """
  Planned steps
  * Extract - Extraction module, Saxy parser.
              Returns _exactly_ what's in the document, not deduped, verified, or filtered.
              However, it IS in a structured format. String keys for fields.

  * Dedup   - Each element is deduped based on that elements uniqueness criteria.

  * Verify  - Each element is verified, filtered, and converted to atomic keys.
              Any invalid elements are discarded.

  * Link & Insert
            - Each element is inserted into the repository. If an association UUID is required,
              it is obtained from previous steps before inserting.


  I think one of the big questions I'm struggling with is this:
  Should the extraction module worry about anything _other than_ extracting?
  On the one one hand, separation of concerns. We can separate extraction from dedup/validation pretty cleanly.
  On the other hand, this extraction module is _already_ pulling into various structures and has to know which values to
  pull at each level. (e.g. It should know to keep the courses parent subject for each course, not just the course attributes.)
  On the other other hand, this extraction will never be complete since we need the parent UUID, not just the parent code.
  So we can't fully verify until we get there.
  On the other other _other_ hand, we don't _NEED_ UUIDs as primary keys. It might fix a lot of issues if we just use the provided
  codes as primary keys. However, this might introduce some problems, since things like course don't have unique keys unto themselves,
  and things like Building have duplicate codes. (So we can't fully rely on these to be unique in all cases.)

  The extraction module should extract and dedup, but not Changeset verify.
  It should contain an initializer function that takes a list of file names to extract from.
  Once all files have been extracted (maybe in parallel?) the results are combined and deduped before being returned.
  Keys will remain as strings, we're not going to worry about verifying missing or invalid keys, etc.
  Associations will include atomic key codes as references.
  Maybe we do this as a distinct key in each one, rather than naming the association?

  i.e. Instead of
  department = %{
    "code" => "AB",
    "name" => "Test Department",
    College => %{code: => "CD"},
  }
  it could be
  department = %{
    fields: %{
      "code" => "AB",
      "name" => "Test Department",
    },
    associations: %{
      College => %{code: "CD"}
    }
  }

  If we separate :fields from :associations, it would make the attribute list cleaner for using Changesets.
  """

  @accepted_tags %{
    "semester" => Semester,
    "campus" => Campus,
    "college" => College,
    "department" => Department,
    "subject" => Subject,
    "bldg" => Building,
    "course" => Course,
    "section" => Section,
    "catalog-description" => :catalog_description,
    "enrollment" => :enrollment,
    "waitlist" => :waitlist,
    "section-title" => :title,
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
      :catalog_description ->
        update_current(current, @accepted_tags[tag], true)
      :crosslists ->
        update_current(current, @accepted_tags[tag], true)
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
            #|> rename_key("part-of-term", "part_of_term")
          )
        end
      :enrollment ->
        current
        |> update_current(Section, %{"enrollment_max" => mattrs["max"]})
        |> update_current(@accepted_tags[tag], true)
      :waitlist ->
        current
        |> update_current(Section, %{"waitlist_max" => mattrs["max"]})
        |> update_current(@accepted_tags[tag], true)
      :fees ->
        update_current(current, @accepted_tags[tag], true)
      :text ->
        update_current(current, @accepted_tags[tag], true)
      :title ->
        update_current(current, @accepted_tags[tag], true)
      :credits ->
        update_current(current, @accepted_tags[tag], true)
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
      {nil, current} -> {completed, current}
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

  # Default element handlers
  def handle_event(:start_element, {_name, _attributes}, state) do
    {:ok, state}
  end

  def handle_event(:end_element, _name, state) do
    {:ok, state}
  end

  def handle_event(:characters, chars, %{current: current, completed: completed}) do
    new_current = case current do
      %{Course => _course, catalog_description: true} ->
        update_current(current, Course, %{"catalog_description" => chars})
      %{Section => _section, enrollment: true} ->
        update_current(current, Section, %{"enrollment" => chars})
      %{Section => _section, waitlist: true} ->
        update_current(current, Section, %{"waitlist" => chars})
      %{Section => _section, title: true} ->
        update_current(current, Section, %{"title" => chars})
      %{Section => _section, text: true} ->
        update_current(current, Section, %{"text" => chars})
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
    updated = Map.merge(current[type] || %{}, updates)
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
