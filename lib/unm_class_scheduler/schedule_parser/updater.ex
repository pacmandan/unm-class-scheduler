defmodule UnmClassScheduler.ScheduleParser.Updater do
  alias UnmClassScheduler.Repo
  alias UnmClassScheduler.ScheduleParser.EventHandler
  alias UnmClassScheduler.Catalog.{
    Semester,
    Campus,
    College,
    Department,
    Subject,
    Course,
    Section,
    PartOfTerm,
    Status,
  }

  def load_from_file(filename) do
    stream = File.stream!(Path.expand(filename))
    {:ok, extracted} = Saxy.parse_stream(stream, EventHandler, EventHandler.init_state())
    mass_insert(extracted)
  end

  def mass_insert(schemas) do
    Ecto.Multi.new()
    # TODO: Add a Repo.get function to the multi to pre-populate
    # the cache with pre-existing static values.
    |> Ecto.Multi.run(
      :semester,
      insert_block(schemas[:semesters],
                   insert_coded_schema(Semester),
                   &get_code/1)
    )
    |> Ecto.Multi.run(
      :campus,
      insert_block(schemas[:campuses],
                   insert_coded_schema(Campus),
                   &get_code/1)
    )
    |> Ecto.Multi.run(
      :college,
      insert_block(schemas[:colleges],
                   insert_coded_schema(College),
                   &get_code/1)
    )
    |> Ecto.Multi.run(
      :department,
      insert_block(schemas[:departments],
                   insert_linked_schema(Department, :departments, :college),
                   &get_code/1)
    )
    |> Ecto.Multi.run(
      :subject,
      insert_block(schemas[:subjects],
                   insert_linked_schema(Subject, :subjects, :department),
                   &get_code/1)
    )
    |> Ecto.Multi.run(
      :course,
      insert_block(schemas[:courses],
                   insert_linked_schema(Course, :courses, :subject),
                   (fn {course, subj} -> course_code(course, subj) end),
                   &(elem(&1, 0)))
    )
    |> Ecto.Multi.run(
      :section,
      insert_block(schemas[:sections],
                   &insert_section/2,
                   &(&1.crn))
    )
    |> Repo.transaction(timeout: 60_000)
  end

  defp repo_insert(changeset, repo, conflict_target) do
    repo.insert!(
      changeset,
      on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
      conflict_target: conflict_target,
      returning: true
    )
  end

  defp cache_inserted(inserted, keyfn, valuefn) do
    Enum.reduce(inserted, %{}, fn value, acc ->
      Map.put(acc, keyfn.(value), valuefn.(value))
    end)
  end

  defp no_op(value) do
    value
  end

  defp get_code({changeset, _}) when is_struct(changeset) do
    get_code(changeset)
  end

  defp get_code(changeset) when is_struct(changeset) do
    changeset.code
  end

  defp course_code(course) when not is_nil(course.subject) do
    course_code(course, course.subject)
  end

  defp course_code(course, subject) when is_struct(course) and is_struct(subject) do
    course_code(course.number, subject.code)
  end

  defp course_code(course_number, subject_code) when is_binary(course_number) and is_binary(subject_code) do
    "#{subject_code}__#{course_number}"
  end

  # FIXME: This is more concise, but WAY harder to understand than it was before.
  # It's nested in a very weird and hard to read way.
  # **Add comments and typespecs to try and clarify this.**
  # DO NOT DELETE THE OLD CODE until this code makes sense!
  # Like, write this for the person who is going to be adding another section to the Multi.

  defp insert_block(insert_attrs, insert_fn, cache_key_fn, cache_value_fn \\ &no_op/1) do
    fn repo, cache ->
      Enum.map(insert_attrs, insert_fn.(repo, cache))
      |> cache_inserted(cache_key_fn, cache_value_fn)
      |> (&({:ok, &1})).()
    end
  end

  # Semester, Campus, College
  defp insert_coded_schema(schema) do
    fn repo, _cache ->
      fn {_, attrs} ->
        struct(schema)
        |> schema.changeset(attrs)
        |> repo_insert(repo, :code)
      end
    end
  end

  # Department, Subject, Course
  defp insert_linked_schema(schema, child_key, parent_attrs_key) do
    fn repo, cache ->
      fn {_, attrs} ->
        with {parent_attrs, attrs} <- attrs |> Map.pop(parent_attrs_key),
          parent <- get_in(cache, [parent_attrs_key, parent_attrs[:code]])
        do
          Ecto.build_assoc(parent, child_key)
          |> schema.changeset(attrs)
          |> repo_insert(repo, :code)
          # Return a tuple of {child, parent}
          # This is useful for caching in some cases. (Specifically Course)
          |> (&({&1, parent})).()
        end
      end
    end
  end

  defp insert_section(repo, cache) do
    fn {_, attrs} ->
      with {subject_attrs, attrs} <- attrs |> Map.pop(:subject),
        {course_attrs, attrs} <- attrs |> Map.pop(:course),
        {semester_attrs, attrs} <- attrs |> Map.pop(:semester),
        {part_of_term_code, attrs} <- attrs |> Map.pop("part_of_term"),
        {status_code, attrs} <- attrs |> Map.pop("status"),
        course <- get_in(cache, [:course, course_code(course_attrs[:number], subject_attrs[:code])]),
        semester <- get_in(cache, [:semester, semester_attrs[:code]]),
        # part_of_term <- Map.get(parts_of_term, part_of_term_code),
        part_of_term <- repo.get_by(PartOfTerm, code: part_of_term_code),
        # status <- Map.get(statuses, status_code)
        status <- repo.get_by(Status, code: status_code)
      do
        Section.create_section(attrs, course, semester, part_of_term, status)
        |> repo_insert(repo, [:crn, :semester_uuid])
      end
    end
  end
end
