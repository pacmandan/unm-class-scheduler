defmodule UnmClassScheduler.Catalog.CrosslistTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Crosslist
  alias UnmClassScheduler.Catalog.Section
  alias UnmClassScheduler.Catalog.Course
  alias UnmClassScheduler.Catalog.Subject

  doctest UnmClassScheduler.Catalog.Crosslist

  defp setup_subject(%{subject_code: subject_code}) do
    {:ok, subject: %Subject{code: subject_code}}
  end

  defp setup_course(%{course_number: course_number, subject: subject}) do
    {:ok, course: %Course{number: course_number, subject: subject}}
  end

  defp setup_section(%{section_uuid: uuid}) do
    {:ok, section: %Section{uuid: uuid}}
  end

  defp setup_crosslist(%{crosslist_uuid: uuid, course: course}) do
    {:ok, crosslist: %Section{uuid: uuid, course: course}}
  end

  describe "validate_data/2" do
    @describetag subject_code: "SUBJ"
    @describetag course_number: "123L"
    @describetag section_uuid: "SEC12345"
    @describetag crosslist_uuid: "SEC67890"

    setup [:setup_subject, :setup_course, :setup_section, :setup_crosslist]

    test "with mismatched subject code", context do
      params = %{subject_code: "NOPE", course_number: context.course_number}
      assert Crosslist.validate_data(params, section: context.section, crosslist: context.crosslist) ==
        {:error, [
          {:crosslist_uuid, {"can't be blank", [validation: :required]}},
          {:subject_code, {"crosslist subject does not match param subject", []}}
        ]}
    end

    test "with mismatched course number", context do
      params = %{subject_code: context.subject_code, course_number: "NOPE"}
      assert Crosslist.validate_data(params, section: context.section, crosslist: context.crosslist) ==
        {:error, [
          {:crosslist_uuid, {"can't be blank", [validation: :required]}},
          {:course_number, {"crosslist course does not match param course", []}}
        ]}
    end

    test "with missing subject_code param", context do
      params = %{course_number: context.course_number}
      assert Crosslist.validate_data(params, section: context.section, crosslist: context.crosslist) ==
        {:error, [
          {:crosslist_uuid, {"can't be blank", [validation: :required]}},
          {:subject_code, {"missing validation param", []}}
        ]}
    end

    test "with missing course_number param", context do
      params = %{subject_code: context.subject_code}
      assert Crosslist.validate_data(params, section: context.section, crosslist: context.crosslist) ==
        {:error, [
          {:crosslist_uuid, {"can't be blank", [validation: :required]}},
          {:course_number, {"missing validation param", []}}
        ]}
    end

    test "with missing crosslist subject", context do
      params = %{subject_code: context.subject_code, course_number: context.course_number}
      crosslist = %Section{
        uuid: context.crosslist_uuid,
        course: %Course{
          number: context.course_number,
        }
      }
      assert Crosslist.validate_data(params, section: context.section, crosslist: crosslist) ==
        {:error, [
          {:crosslist_uuid, {"can't be blank", [validation: :required]}},
          {:crosslist, {"crosslist Course and Subject must be preloaded", []}},
        ]}
    end

    test "with missing crosslist course", context do
      params = %{subject_code: context.subject_code, course_number: context.course_number}
      crosslist = %Section{
        uuid: context.crosslist_uuid,
      }
      assert Crosslist.validate_data(params, section: context.section, crosslist: crosslist) ==
        {:error, [
          {:crosslist_uuid, {"can't be blank", [validation: :required]}},
          {:crosslist, {"crosslist Course and Subject must be preloaded", []}},
        ]}
    end

    @tag crosslist_uuid: nil
    test "with missing crosslist uuid", context do
      params = %{subject_code: context.subject_code, course_number: context.course_number}
      assert Crosslist.validate_data(params, section: context.section, crosslist: context.crosslist) ==
        {:error, [
          {:crosslist_uuid, {"can't be blank", [validation: :required]}},
        ]}
    end

    @tag section_uuid: nil
    test "with missing section uuid", context do
      params = %{subject_code: context.subject_code, course_number: context.course_number}
      assert Crosslist.validate_data(params, section: context.section, crosslist: context.crosslist) ==
        {:error, [
          {:section_uuid, {"can't be blank", [validation: :required]}},
        ]}
    end

    test "with missing section", context do
      params = %{subject_code: context.subject_code, course_number: context.course_number}
      assert Crosslist.validate_data(params, section: nil, crosslist: context.crosslist) ==
        {:error, [
          {:section_uuid, {"can't be blank", [validation: :required]}},
        ]}
    end
  end
end
