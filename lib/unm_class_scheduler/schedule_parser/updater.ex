defmodule UnmClassScheduler.ScheduleParser.Updater do
  alias UnmClassScheduler.Repo
  alias UnmClassScheduler.ScheduleParser.Extractor
  alias UnmClassScheduler.Catalog.{
    Semester,
    Campus,
    Building,
    College,
    Department,
    Subject,
    Course,
    Section,
    PartOfTerm,
    Status,
    MeetingTime,
    Crosslist,
    Instructor,
  }

  import Ecto.Query

  def load_from_files(filenames) do
    filenames
    |> Extractor.extract_from()
    |> mass_insert()
  end

  def mass_insert(extracted_attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(
      :parts_of_term,
      fetch_coded_and_cache_all(PartOfTerm)
    )
    |> Ecto.Multi.run(
      :statuses,
      fetch_coded_and_cache_all(Status)
    )
    |> Ecto.Multi.run(
      Semester,
      insert_schemaless(extracted_attrs[Semester], Semester)
    )
    |> Ecto.Multi.run(
      Campus,
      insert_schemaless(extracted_attrs[Campus], Campus)
    )
    |> Ecto.Multi.run(
      Building,
      insert_linked_schemaless(extracted_attrs[Building], Building, &building_key/2)
    )
    |> Ecto.Multi.run(
      College,
      insert_schemaless(extracted_attrs[College], College)
    )
    |> Ecto.Multi.run(
      Department,
      insert_linked_schemaless(extracted_attrs[Department], Department)
    )
    |> Ecto.Multi.run(
      Subject,
      insert_linked_schemaless(extracted_attrs[Subject], Subject)
    )
    |> Ecto.Multi.run(
      Course,
      insert_linked_schemaless(extracted_attrs[Course], Course, &course_key/2)
    )
    |> Ecto.Multi.run(
      Section,
      insert_sections_schemaless(extracted_attrs[Section])
    )
    |> Ecto.Multi.run(
      MeetingTime,
      insert_meeting_times_schemaless(extracted_attrs[MeetingTime])
    )
    |> Ecto.Multi.run(
      Crosslist,
      insert_crosslists(extracted_attrs[Crosslist])
    )
    |> Ecto.Multi.run(
      Instructor,
      insert_schemaless(extracted_attrs[Instructor], Instructor, &get_email/1)
    )
    |> Repo.transaction(timeout: 60_000)
  end

  defp repo_insert_all(entries, schema, repo, placeholders) do
    repo.insert_all(
      schema,
      entries,
      on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
      conflict_target: schema.conflict_keys(),
      returning: true,
      placeholders: placeholders
    )
    |> elem(1)
  end

  defp fetch_coded_and_cache_all(schema) do
    fn repo, _cache ->
      repo.all(from(schema))
      |> Enum.reduce(%{}, fn m, acc ->
        Map.put(acc, m.code, m)
      end)
      |> (&({:ok, &1})).()
    end
  end

  defp get_code(i), do: i.code

  defp get_code(i, _p), do: i.code

  defp get_email(i), do: i.email

  defp building_key(building, campus) do
    building_code(campus.code, building.code)
  end

  defp course_key(course, subject) do
    course_code(subject.code, course.number)
  end

  defp course_code(subject_code, course_number) do
    "#{subject_code}__#{course_number}"
  end

  defp building_code(campus_code, building_code) do
    "#{campus_code}__#{building_code}"
  end

  defp insert_schemaless(attrs_to_insert, schema, cache_key_fn \\ &get_code/1) do
    fn repo, _cache ->
      placeholders = %{
        now: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
      Enum.map(attrs_to_insert, fn %{fields: f} ->
        {:ok, valid_f} = schema.validate_data(f)
        valid_f
        |> Map.merge(%{
          inserted_at: {:placeholder, :now},
          updated_at: {:placeholder, :now},
        })
      end)
      |> repo_insert_all(schema, repo, placeholders)
      |> Stream.map((&({cache_key_fn.(&1), &1})))
      |> Enum.into(%{})
      |> (&({:ok, &1})).()
    end
  end

  defp insert_linked_schemaless(attrs_to_insert, schema, cache_key_fn \\ &get_code/2) do
    fn repo, cache ->
      placeholders = %{
        now: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
      Enum.map(attrs_to_insert, fn %{fields: f, associations: a} ->
        parent = get_in(cache, [schema.parent_module(), a[schema.parent_module()][:code]])
        {:ok, valid_f} = schema.validate_data(f, [{schema.parent_key(), parent}])
        valid_f
        |> Map.merge(%{
          inserted_at: {:placeholder, :now},
          updated_at: {:placeholder, :now},
        })
      end)
      |> repo_insert_all(schema, repo, placeholders)
      |> repo.preload(schema.parent_key())
      |> Stream.map(fn inserted -> {cache_key_fn.(inserted, schema.get_parent(inserted)), inserted} end)
      |> Enum.into(%{})
      |> (&({:ok, &1})).()
    end
  end

  defp insert_sections_schemaless(attrs_to_insert) do
    fn repo, cache ->
      placeholders = %{
        now: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
      Stream.map(attrs_to_insert, fn %{fields: f, associations: a} ->
        course = get_in(cache, [Course, course_code(a[Subject][:code], a[Course][:number])])
        semester = get_in(cache, [Semester, a[Semester][:code]])
        part_of_term = get_in(cache, [:parts_of_term, a[:part_of_term][:code]])
        status = get_in(cache, [:statuses, a[:status][:code]])
        {:ok, valid_f} = Section.validate_data(f, course: course, semester: semester, part_of_term: part_of_term, status: status)

        valid_f
        |> Map.merge(%{
          inserted_at: {:placeholder, :now},
          updated_at: {:placeholder, :now},
        })
      end)
      |> Stream.chunk_every(3000)
      |> Enum.map(fn list -> repo_insert_all(list, Section, repo, placeholders) end)
      |> Enum.reduce([], fn inserted, acc -> acc ++ inserted end)
      |> repo.preload([:semester, course: :subject])
      |> Stream.map((&({"#{&1.crn}__#{&1.semester.code}", &1})))
      |> Enum.into(%{})
      |> (&({:ok, &1})).()
    end
  end

  defp insert_meeting_times_schemaless(attrs_to_insert) do
    fn repo, cache ->
      placeholders = %{
        now: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
      Stream.map(attrs_to_insert, fn %{fields: f, associations: a} ->
        section = get_in(cache, [Section, "#{a[Section][:crn]}__#{a[Semester][:code]}"])
        building = get_in(cache, [Building, building_code(a[Campus][:code], a[Building][:code])])
        {:ok, valid_f} = MeetingTime.validate_data(f, section: section, building: building)

        valid_f
        |> Map.merge(%{
          inserted_at: {:placeholder, :now},
          updated_at: {:placeholder, :now},
        })
      end)
      |> Stream.chunk_every(3000)
      |> Enum.map(fn list -> repo_insert_all(list, MeetingTime, repo, placeholders) end)
      |> Enum.reduce([], fn inserted, acc -> acc ++ inserted end)
      |> (&({:ok, &1})).()
    end
  end

  defp insert_crosslists(attrs_to_insert) do
    fn repo, cache ->
      placeholders = %{
        now: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
      Stream.map(attrs_to_insert, fn %{fields: f, associations: a} ->
        section = get_in(cache, [Section, "#{a[:section][:crn]}__#{a[Semester][:code]}"])
        crosslist = get_in(cache, [Section, "#{a[:crosslist][:crn]}__#{a[Semester][:code]}"])

        case Crosslist.validate_data(f, section: section, crosslist: crosslist) do
          {:ok, valid_f} ->
            valid_f
            |> Map.merge(%{
              inserted_at: {:placeholder, :now},
              updated_at: {:placeholder, :now},
            })
          # There are some crosslists in the data that are expected to be invalid.
          # In which case, we just reject them.
          {:error, _err} ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> repo_insert_all(Crosslist, repo, placeholders)
      |> (&({:ok, &1})).()
    end
  end
end
