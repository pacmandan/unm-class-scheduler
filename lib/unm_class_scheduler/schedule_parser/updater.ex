defmodule UnmClassScheduler.ScheduleParser.Updater do
  @moduledoc """
  Takes extracted attributes and inserts them into the Repo.
  """

  alias UnmClassScheduler.Repo
  alias UnmClassScheduler.Catalog.Semester
  alias UnmClassScheduler.Catalog.Campus
  alias UnmClassScheduler.Catalog.Building
  alias UnmClassScheduler.Catalog.College
  alias UnmClassScheduler.Catalog.Department
  alias UnmClassScheduler.Catalog.Subject
  alias UnmClassScheduler.Catalog.Course
  alias UnmClassScheduler.Catalog.Section
  alias UnmClassScheduler.Catalog.PartOfTerm
  alias UnmClassScheduler.Catalog.Status
  alias UnmClassScheduler.Catalog.MeetingTime
  alias UnmClassScheduler.Catalog.Crosslist
  alias UnmClassScheduler.Catalog.Instructor
  alias UnmClassScheduler.Catalog.DeliveryType
  alias UnmClassScheduler.Catalog.InstructionalMethod
  alias UnmClassScheduler.Catalog.InstructorSection

  import Ecto.Query

  @spec mass_insert(map()) :: any()
  def mass_insert(extracted_attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(
      PartOfTerm,
      (fn repo, _ -> fetch_coded_and_cache_all(repo, PartOfTerm) end)
    )
    |> Ecto.Multi.run(
      Status,
      (fn repo, _ -> fetch_coded_and_cache_all(repo, Status) end)
    )
    |> Ecto.Multi.run(
      DeliveryType,
      (fn repo, _ -> fetch_coded_and_cache_all(repo, DeliveryType) end)
    )
    |> Ecto.Multi.run(
      InstructionalMethod,
      (fn repo, _ -> fetch_coded_and_cache_all(repo, InstructionalMethod) end)
    )
    |> Ecto.Multi.run(
      Semester,
      (fn repo, _ -> insert_records(repo, extracted_attrs[Semester], Semester) end)
    )
    |> Ecto.Multi.run(
      Campus,
      (fn repo, _ -> insert_records(repo, extracted_attrs[Campus], Campus) end)
    )
    |> Ecto.Multi.run(
      Building,
      (fn repo, cache -> insert_linked_records(repo, cache, extracted_attrs[Building], Building, &building_key/2) end)
    )
    |> Ecto.Multi.run(
      College,
      (fn repo, _ -> insert_records(repo, extracted_attrs[College], College) end)
    )
    |> Ecto.Multi.run(
      Department,
      (fn repo, cache -> insert_linked_records(repo, cache, extracted_attrs[Department], Department) end)
    )
    |> Ecto.Multi.run(
      Subject,
      (fn repo, cache -> insert_linked_records(repo, cache, extracted_attrs[Subject], Subject) end)
    )
    |> Ecto.Multi.run(
      Course,
      (fn repo, cache -> insert_linked_records(repo, cache, extracted_attrs[Course], Course, &course_key/2) end)
    )
    |> Ecto.Multi.run(
      Section,
      (fn repo, cache -> insert_sections(repo, cache, extracted_attrs[Section]) end)
    )
    |> Ecto.Multi.run(
      MeetingTime,
      (fn repo, cache -> insert_meeting_times(repo, cache, extracted_attrs[MeetingTime]) end)
    )
    |> Ecto.Multi.run(
      Crosslist,
      (fn repo, cache -> insert_crosslists(repo, cache, extracted_attrs[Crosslist]) end)
    )
    |> Ecto.Multi.run(
      Instructor,
      (fn repo, _ -> insert_records(repo, extracted_attrs[Instructor], Instructor, &instructor_key/1) end)
    )
    |> Ecto.Multi.run(
      InstructorSection,
      (fn repo, cache -> insert_instructors_sections(repo, cache, extracted_attrs[InstructorSection]) end)
    )
    |> Ecto.Multi.run(
      :deleted,
      &delete_all_not_updated/2
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

  defp fetch_coded_and_cache_all(repo, schema) do
    repo.all(from(schema))
    |> Enum.reduce(%{}, fn m, acc ->
      Map.put(acc, m.code, m)
    end)
    |> (&({:ok, &1})).()
  end

  defp get_code(i), do: i.code

  defp get_code(i, _p), do: i.code

  defp instructor_key(i), do: "#{i.email}_#{i.first}_#{i.last}"

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

  defp generate_placeholders() do
    %{now: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)}
  end

  defp merge_placeholders(fields) do
    Map.merge(fields, %{
      inserted_at: {:placeholder, :now},
      updated_at: {:placeholder, :now},
    })
  end

  defp insert_records(repo, attrs_to_insert, schema, cache_key_fn \\ &get_code/1) do
    Enum.map(attrs_to_insert, fn %{fields: f} ->
      {:ok, valid_f} = schema.validate_data(f)
      valid_f
      |> merge_placeholders()
    end)
    |> repo_insert_all(schema, repo, generate_placeholders())
    |> Stream.map((&({cache_key_fn.(&1), &1})))
    |> Enum.into(%{})
    |> (&({:ok, &1})).()
  end

  defp insert_linked_records(repo, cache, attrs_to_insert, schema, cache_key_fn \\ &get_code/2) do
    Enum.map(attrs_to_insert, fn %{fields: f, associations: a} ->
      parent = get_in(cache, [schema.parent_module(), a[schema.parent_module()][:code]])
      {:ok, valid_f} = schema.validate_data(f, [{schema.parent_key(), parent}])
      valid_f
      |> merge_placeholders()
    end)
    |> repo_insert_all(schema, repo, generate_placeholders())
    |> repo.preload(schema.parent_key())
    |> Stream.map(fn inserted -> {cache_key_fn.(inserted, schema.get_parent(inserted)), inserted} end)
    |> Enum.into(%{})
    |> (&({:ok, &1})).()
  end

  defp insert_sections(repo, cache, attrs_to_insert) do
    Stream.map(attrs_to_insert, fn %{fields: f, associations: a} ->
      course = get_in(cache, [Course, course_code(a[Subject][:code], a[Course][:number])])
      semester = get_in(cache, [Semester, a[Semester][:code]])
      part_of_term = get_in(cache, [PartOfTerm, a[PartOfTerm][:code]])
      status = get_in(cache, [Status, a[Status][:code]])
      delivery_type = get_in(cache, [DeliveryType, a[DeliveryType][:code]])
      instructional_method = get_in(cache, [InstructionalMethod, a[InstructionalMethod][:code]])
      campus = get_in(cache, [Campus, a[Campus][:code]])
      # TODO: Raise an error if part_of_term, status, delivery_type, or instructional method are unknown.
      # We need to update the database seeds in that case. (I guess a data migration?)
      {:ok, valid_f} = Section.validate_data(
        f,
        course: course,
        semester: semester,
        campus: campus,
        part_of_term: part_of_term,
        status: status,
        delivery_type: delivery_type,
        instructional_method: instructional_method
      )

      valid_f
      |> merge_placeholders()
    end)
    |> Stream.chunk_every(3000)
    |> Enum.map(fn list -> repo_insert_all(list, Section, repo, generate_placeholders()) end)
    |> Enum.reduce([], fn inserted, acc -> acc ++ inserted end)
    |> repo.preload([:semester, course: :subject])
    |> Stream.map((&({"#{&1.crn}__#{&1.semester.code}", &1})))
    |> Enum.into(%{})
    |> (&({:ok, &1})).()
  end

  defp insert_meeting_times(repo, cache, attrs_to_insert) do
    Stream.map(attrs_to_insert, fn %{fields: f, associations: a} ->
      section = get_in(cache, [Section, "#{a[Section][:crn]}__#{a[Semester][:code]}"])
      building = get_in(cache, [Building, building_code(a[Campus][:code], a[Building][:code])])
      {:ok, valid_f} = MeetingTime.validate_data(f, section: section, building: building)

      valid_f
      |> merge_placeholders()
    end)
    |> Stream.chunk_every(3000)
    |> Enum.map(fn list -> repo_insert_all(list, MeetingTime, repo, generate_placeholders()) end)
    |> Enum.reduce([], fn inserted, acc -> acc ++ inserted end)
    |> (&({:ok, &1})).()
  end

  defp insert_crosslists(repo, cache, attrs_to_insert) do
    Stream.map(attrs_to_insert, fn %{fields: f, associations: a} ->
      section = get_in(cache, [Section, "#{a[:section][:crn]}__#{a[Semester][:code]}"])
      crosslist = get_in(cache, [Section, "#{a[:crosslist][:crn]}__#{a[Semester][:code]}"])

      case Crosslist.validate_data(f, section: section, crosslist: crosslist) do
        {:ok, valid_f} ->
          valid_f
          |> merge_placeholders()
        # There are some crosslists in the data that are expected to be invalid.
        # In which case, we just reject them.
        {:error, _err} ->
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> repo_insert_all(Crosslist, repo, generate_placeholders())
    |> (&({:ok, &1})).()
  end

  defp insert_instructors_sections(repo, cache, attrs_to_insert) do
    Enum.map(attrs_to_insert, fn %{fields: f, associations: a} ->
      section = get_in(cache, [Section, "#{a[Section][:crn]}__#{a[Semester][:code]}"])
      instructor = get_in(cache, [Instructor, "#{a[Instructor][:email]}_#{a[Instructor][:first]}_#{a[Instructor][:last]}"])

      {:ok, valid_f} = InstructorSection.validate_data(f, section: section, instructor: instructor)
      valid_f
      |> merge_placeholders()
    end)
    |> Stream.chunk_every(15_000)
    |> Enum.map(fn list -> repo_insert_all(list, InstructorSection, repo, generate_placeholders()) end)
    |> Enum.reduce([], fn inserted, acc -> acc ++ inserted end)
    |> (&({:ok, &1})).()
  end

  # Everything that we didn't update in this round should be deleted.
  # TODO: Maybe make this optional to the updater?
  # That would give much more flexability in case we need to update just one file or something.
  defp delete_all_not_updated(repo, cache) do
    deleted = %{
      InstructorSection => cache[InstructorSection] |> delete_not_updated(repo, InstructorSection),
      Instructor => Map.values(cache[Instructor]) |> delete_not_updated(repo, Instructor),
      Crosslist => cache[Crosslist] |> delete_not_updated(repo, Crosslist),
      MeetingTime => cache[MeetingTime] |> delete_not_updated(repo, MeetingTime),
      Section => Map.values(cache[Section]) |> delete_not_updated(repo, Section),
      Course => Map.values(cache[Course]) |> delete_not_updated(repo, Course),
      Subject => Map.values(cache[Subject]) |> delete_not_updated(repo, Subject),
      Department => Map.values(cache[Department]) |> delete_not_updated(repo, Department),
      College => Map.values(cache[College]) |> delete_not_updated(repo, College),
      Building => Map.values(cache[Building]) |> delete_not_updated(repo, Building),
      Campus => Map.values(cache[Campus]) |> delete_not_updated(repo, Campus),
      Semester => Map.values(cache[Semester]) |> delete_not_updated(repo, Semester),
    }
    {:ok, deleted}
  end

  defp delete_not_updated(updated, repo, type) do
    uuids = updated |> Enum.map((&(&1.uuid)))
    q = from(i in type, where: i.uuid not in ^uuids)
    repo.delete_all(q)
  end
end
