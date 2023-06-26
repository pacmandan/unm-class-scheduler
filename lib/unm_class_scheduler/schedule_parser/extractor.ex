defmodule UnmClassScheduler.ScheduleParser.Extractor do
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
    MeetingTime,
  }
  alias UnmClassScheduler.ScheduleParser.ExtractedItem

  @type current_state_t :: %{atom() => ExtractedItem.t()}
  @type completed_state_t :: %{atom() => list(ExtractedItem.t())}
  @type state_t :: %{
    current: current_state_t,
    completed: completed_state_t,
  }

  @tags %{
    "semester" => Semester,
    "campus" => Campus,
    "college" => College,
    "department" => Department,
    "subject" => Subject,
    "bldg" => Building,
    "course" => Course,
    "section" => Section,
    "meeting-time" => MeetingTime,
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
  @accepted_tags Map.keys(@tags)

  @attribute_maps %{
    Semester => %{
      "code" => :code,
      "name" => :name,
    },
    Campus => %{
      "code" => :code,
      "name" => :name,
    },
    Building => %{
      "code" => :code,
      "name" => :name,
    },
    College => %{
      "code" => :code,
      "name" => :name,
    },
    Department => %{
      "code" => :code,
      "name" => :name,
    },
    Subject => %{
      "code" => :code,
      "name" => :name,
    },
    Course => %{
      "number" => :number,
      "title" => :title,
    },
    Section => %{
      "crn" => :crn,
      "number" => :number,
      "part-of-term" => :part_of_term_code,
      "status" => :status_code,
    },
  }
  @accepted_types Map.keys(@attribute_maps)

  def extract_from(filenames) do
    filenames
    |> Enum.reduce(init_completed(), fn filename, acc ->
      {:ok, extracted} = File.stream!(Path.expand(filename))
      |> Saxy.parse_stream(__MODULE__, acc)

      for {type, list} <- acc, into: %{}, do: {type, list ++ extracted[type]}
    end)
    |> dedup_extracted
  end

  defp init_completed() do
    %{
      Semester => [],
      Campus => [],
      Building => [],
      College => [],
      Department => [],
      Subject => [],
      Course => [],
      Section => [],
      MeetingTime => [],
    }
  end

  defp dedup_extracted(extracted) do
    %{
      Semester => (extracted[Semester] |> Enum.uniq_by((&(&1.fields[:code])))),
      Campus => (extracted[Campus] |> Enum.uniq_by((&(&1.fields[:code])))),
      Building => extracted[Building]
        |> Enum.reject((&(&1.fields[:code] == "")))
        |> Enum.uniq_by((&({&1.fields[:code], &1.associations[Campus][:code]}))),
      College => extracted[College] |> Enum.uniq_by((&(&1.fields[:code]))),
      Department => extracted[Department] |> Enum.uniq_by((&(&1.fields[:code]))),
      Subject => extracted[Subject] |> Enum.uniq_by((&(&1.fields[:code]))),
      Course => extracted[Course] |> Enum.uniq_by((&({&1.fields[:number], &1.associations[Subject][:code]}))),
      Section => extracted[Section] |> Enum.uniq_by((&({&1.fields[:crn], &1.associations[Semester][:code]}))),
      MeetingTime => extracted[MeetingTime]
    }
  end

  defp init_state(existing) when is_map(existing) do # \\ []
    %{
      completed: existing,
      current: %{},
    }
  end

  defp transform_fields(fields, type) when type in @accepted_types do
    fields
    |> Map.new()
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      case @attribute_maps[type][k] do
        nil -> acc
        tk -> Map.put(acc, tk, v)
      end
    end)
  end

  def handle_event(:start_document, _prolog, state) do
    {:ok, init_state(state)}
  end

  def handle_event(:end_document, _data, %{completed: completed}) do
    {:ok, completed}
  end

  def handle_event(:start_element, {"semester", attrs}, %{current: c} = state) do
    ex = %ExtractedItem{fields: transform_fields(attrs, Semester)}

    {:ok, state |> Map.put(:current, update_current(c, Semester, ex))}
  end

  def handle_event(:start_element, {"campus", attrs}, %{current: c} = state) do
    ex = %ExtractedItem{fields: transform_fields(attrs, Campus)}

    {:ok, state |> Map.put(:current, update_current(c, Campus, ex))}
  end

  def handle_event(:start_element, {"college", attrs}, %{current: c} = state) do
    ex = %ExtractedItem{fields: transform_fields(attrs, College)}

    {:ok, state |> Map.put(:current, update_current(c, College, ex))}
  end

  def handle_event(:start_element, {"department", attrs}, %{current: c} = state) do
    ex = %ExtractedItem{
      fields: transform_fields(attrs, Department),
      associations: %{College => %{code: c[College].fields[:code]}},
    }

    {:ok, state |> Map.put(:current, update_current(c, Department, ex))}
  end

  def handle_event(:start_element, {"subject", attrs}, %{current: c} = state) do
    ex = %ExtractedItem{
      fields: transform_fields(attrs, Subject),
      associations: %{Department => %{code: c[Department].fields[:code]}},
    }

    {:ok, state |> Map.put(:current, update_current(c, Subject, ex))}
  end

  def handle_event(:start_element, {"course", attrs}, %{current: c} = state) do
    ex = %ExtractedItem{
      fields: transform_fields(attrs, Course),
      associations: %{Subject => %{code: c[Subject].fields[:code]}},
    }

    {:ok, state |> Map.put(:current, update_current(c, Course, ex))}
  end

  def handle_event(:start_element, {"catalog-description", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :catalog_description, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{Course => course, catalog_description: true} = c} = state
  ) do
    ex = ExtractedItem.push_fields(course, %{catalog_description: chars})
    {:ok, state |> Map.put(:current, update_current(c, Course, ex))}
  end

  def handle_event(:start_element, {"bldg", attrs}, %{current: c} = state) do
    fields = transform_fields(attrs, Building)
    ex = %ExtractedItem{
      fields: fields,
      associations: %{Campus => %{code: c[Campus].fields[:code]}},
    }
    mt = ExtractedItem.push_associations(c[MeetingTime], %{Building => %{code: fields[:code]}})

    new_current = update_current(c, Building, ex)
    |> update_current(MeetingTime, mt)

    {:ok, state |> Map.put(:current, new_current)}
  end

  def handle_event(:characters, chars,
    %{current: %{Building => building} = c} = state
  ) do
    ex = ExtractedItem.push_fields(building, %{name: chars})
    {:ok, state |> Map.put(:current, update_current(c, Building, ex))}
  end


  def handle_event(:start_element, {"section", attrs}, %{current: c} = state) do
    new_current = if c[:crosslists] do
      # TODO: Extract to crosslists of existing Section
      c
    else
      fields = transform_fields(attrs, Section)
      |> Map.put(:num_meetings, 0)
      ex = %ExtractedItem{
        fields: Map.drop(fields, [:part_of_term_code, :status_code]),
        associations: %{
          Subject => %{code: c[Subject].fields[:code]},
          Course => %{number: c[Course].fields[:number]},
          Semester => %{code: c[Semester].fields[:code]},
          part_of_term: %{code: fields[:part_of_term_code]},
          status: %{code: fields[:status_code]},
        },
      }
      update_current(c, Section, ex)
    end

    {:ok, state |> Map.put(:current, new_current)}
  end

  def handle_event(:start_element, {"crosslists", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :crosslists, true))}
  end

  def handle_event(:start_element, {"fees", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :fees, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{Section => section, fees: true} = c} = state
  ) do
    # Extract to float instead of raw string.
    {fees, _} = Float.parse(chars)
    ex = ExtractedItem.push_fields(section, %{fees: fees})
    {:ok, state |> Map.put(:current, update_current(c, Section, ex))}
  end

  def handle_event(:start_element, {"text", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :text, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{Section => section, text: true} = c} = state
  ) do
    ex = ExtractedItem.push_fields(section, %{text: chars})
    {:ok, state |> Map.put(:current, update_current(c, Section, ex))}
  end

  def handle_event(:start_element, {"section-title", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :section_title, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{Section => section, section_title: true} = c} = state
  ) do
    ex = ExtractedItem.push_fields(section, %{title: chars})
    {:ok, state |> Map.put(:current, update_current(c, Section, ex))}
  end

  def handle_event(:start_element, {"credits", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :credits, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{Section => section, credits: true} = c} = state
  ) do
    # TODO: Credits can either be formatted as "3" or "1 TO 6".
    # Split this and make it so these can be read as numbers.
    ex = ExtractedItem.push_fields(section, %{credits: chars})
    {:ok, state |> Map.put(:current, update_current(c, Section, ex))}
  end

  def handle_event(:start_element, {"enrollment", [{"max", max}]}, %{current: c} = state) do
    section = ExtractedItem.push_fields(c[Section], %{enrollment_max: max})
    new_current = update_current(c, Section, section)
    |> update_current(:enrollment, true)
    {:ok, state |> Map.put(:current, new_current)}
  end

  def handle_event(:characters, chars,
    %{current: %{Section => section, enrollment: true} = c} = state
  ) do
    ex = ExtractedItem.push_fields(section, %{enrollment: chars})
    {:ok, state |> Map.put(:current, update_current(c, Section, ex))}
  end

  def handle_event(:start_element, {"waitlist", [{"max", max}]}, %{current: c} = state) do
    section = ExtractedItem.push_fields(c[Section], %{waitlist_max: max})
    new_current = update_current(c, Section, section)
    |> update_current(:waitlist, true)

    {:ok, state |> Map.put(:current, new_current)}
  end

  def handle_event(:characters, chars,
    %{current: %{Section => section, waitlist: true} = c} = state
  ) do
    ex = ExtractedItem.push_fields(section, %{waitlist: chars})
    {:ok, state |> Map.put(:current, update_current(c, Section, ex))}
  end

  def handle_event(:start_element, {"meeting-time", _}, %{current: c} = state) do
    section = ExtractedItem.push_fields(c[Section],
      %{num_meetings: c[Section].fields[:num_meetings] + 1}
    )
    ex = %ExtractedItem{
      fields: MeetingTime.init_days()
        |> Map.put(:index, section.fields[:num_meetings] - 1),
      associations: %{
        Section => %{crn: section.fields[:crn]},
        Campus => %{code: c[Campus].fields[:code]},
      }
    }
    new_current = update_current(c, MeetingTime, ex)
    |> update_current(Section, section)

    {:ok, state |> Map.put(:current, new_current)}
  end

  def handle_event(:start_element, {"start-date", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :start_date, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{MeetingTime => mt, start_date: true} = c} = state
  ) do
    # Dates are formatted "YYYY-MM-DD".

    # Alternate in case this ever stops working:
    # date =
    #   chars
    #   |> String.split("-")
    #   |> Enum.map(&String.to_integer/1)
    #   |> (fn [year, month, day] -> Date.new!(year, month, day) end).()

    date = Date.from_iso8601!(chars)
    ex = ExtractedItem.push_fields(mt, %{start_date: date})
    {:ok, state |> Map.put(:current, update_current(c, MeetingTime, ex))}
  end


  def handle_event(:start_element, {"end-date", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :end_date, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{MeetingTime => mt, end_date: true} = c} = state
  ) do
    # Dates are formatted "YYYY-MM-DD".

    # Alternate in case this ever stops working:
    # date =
    #   chars
    #   |> String.split("-")
    #   |> Enum.map(&String.to_integer/1)
    #   |> (fn [year, month, day] -> Date.new!(year, month, day) end).()

    date = Date.from_iso8601!(chars)
    ex = ExtractedItem.push_fields(mt, %{end_date: date})
    {:ok, state |> Map.put(:current, update_current(c, MeetingTime, ex))}
  end

  def handle_event(:start_element, {"start-time", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :start_time, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{MeetingTime => mt, start_time: true} = c} = state
  ) do
    time = chars
    |> String.split_at(2)
    |> Tuple.to_list()
    |> Enum.map(&String.to_integer/1)
    |> (fn [hour, minute] -> Time.new!(hour, minute, 0) end).()

    ex = ExtractedItem.push_fields(mt, %{start_time: time})
    {:ok, state |> Map.put(:current, update_current(c, MeetingTime, ex))}
  end

  def handle_event(:start_element, {"end-time", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :end_time, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{MeetingTime => mt, end_time: true} = c} = state
  ) do
    time = chars
    |> String.split_at(2)
    |> Tuple.to_list()
    |> Enum.map(&String.to_integer/1)
    |> (fn [hour, minute] -> Time.new!(hour, minute, 0) end).()

    ex = ExtractedItem.push_fields(mt, %{end_time: time})
    {:ok, state |> Map.put(:current, update_current(c, MeetingTime, ex))}
  end

  def handle_event(:start_element, {"day", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :day, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{MeetingTime => mt, day: true} = c} = state
  ) do
    day = MeetingTime.day_from_string(chars)
    ex = ExtractedItem.push_fields(mt, %{day => true})
    {:ok, state |> Map.put(:current, update_current(c, MeetingTime, ex))}
  end

  def handle_event(:start_element, {"room", _}, %{current: c} = state) do
    {:ok, state |> Map.put(:current, update_current(c, :room, true))}
  end

  def handle_event(:characters, chars,
    %{current: %{MeetingTime => mt, room: true} = c} = state
  ) do
    ex = ExtractedItem.push_fields(mt, %{room: chars})
    {:ok, state |> Map.put(:current, update_current(c, MeetingTime, ex))}
  end

  # Default :start_element handler
  def handle_event(:start_element, _, state) do
    {:ok, state}
  end

  # No need for :end_element handlers for every tag.
  # They all do the same thing - pop the current off and move it to completed.
  # (If it's nil or true, just pop it from the current list - nothing to complete here.)
  def handle_event(:end_element, tag, %{current: current, completed: completed}) do
    {new_completed, new_current} = case Map.pop(current, @tags[tag]) do
      # Not a tag we pushed to current? Nothing new in completed.
      {nil, rest} -> {completed, rest}
      # Tag that only had chars? Nothing new in completed.
      {true, rest} -> {completed, rest}
      # Actual completed element? Push to the appropriate completed list.
      {done, rest} -> {push_completed(completed, @tags[tag], done), rest}
    end
    new_state = %{
      current: new_current,
      completed: new_completed,
    }
    {:ok, new_state}
  end

  # Default :characters handler
  def handle_event(:characters, _chars, %{current: _current} = state) do
    {:ok, state}
  end

  defp update_current(current, type, updated) do
    Map.put(current, type, updated)
  end

  defp push_completed(completed_lists, type, new_element) do
    completed_lists
    |> Map.update!(type, fn completed -> [new_element | completed] end)
  end
end