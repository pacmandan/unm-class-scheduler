defmodule UnmClassScheduler.Catalog.CourseTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Course
  alias UnmClassScheduler.Catalog.Subject

  doctest UnmClassScheduler.Catalog.Course

  defp setup_subject(context) do
    {:ok, subject: %Subject{uuid: context.subject_uuid, code: "SUB", name: "Test Subject"}}
  end

  defp setup_course(context) do
    params = Map.take(context, [:number, :title, :catalog_description, :extra])
    |> Enum.reject(fn {_, k} -> is_nil(k) end)
    |> Enum.into(%{})

    {:ok, course: params}
  end

  describe "validate_data/2" do
    @describetag subject_uuid: "SUB12345"

    @describetag number: "123L"
    @describetag title: "Test Course"
    @describetag catalog_description: "This is a test course."
    @describetag extra: nil

    setup [:setup_subject, :setup_course]

    @tag extra: "value"
    test "when an extra parameter is provided", %{subject: subject, course: course} do
      assert Course.validate_data(course, subject: subject) ==
        {:ok, %{number: "123L", title: "Test Course", catalog_description: "This is a test course.", subject_uuid: "SUB12345"}}
    end

    @tag number: nil
    test "when number is not given", %{subject: subject, course: course} do
      assert Course.validate_data(course, subject: subject) ==
        {:error, [number: {"can't be blank", [{:validation, :required}]}]}
    end

    @tag title: nil
    test "when title is not given", %{subject: subject, course: course} do
      assert Course.validate_data(course, subject: subject) ==
        {:error, [title: {"can't be blank", [{:validation, :required}]}]}
    end

    @tag catalog_description: nil
    test "when catalog description is not given", %{subject: subject, course: course} do
      assert Course.validate_data(course, subject: subject) ==
        {:ok, %{number: "123L", title: "Test Course", subject_uuid: "SUB12345"}}
    end

    test "when given empty parameters", %{subject: subject} do
      assert Course.validate_data(%{}, subject: subject) ==
        {:error, [
          number: {"can't be blank", [{:validation, :required}]},
          title: {"can't be blank", [{:validation, :required}]},
        ]}
    end

    @tag subject_uuid: nil
    test "when the parent has no uuid", %{subject: subject, course: course} do
      assert Course.validate_data(course, subject: subject) ==
        {:error, [subject_uuid: {"can't be blank", [validation: :required]}]}
    end

    test "when no parent is given", %{course: course} do
      assert Course.validate_data(course, subject: nil) ==
        {:error, [subject_uuid: {"can't be blank", [validation: :required]}]}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(Course.serialize(nil))
    end
  end
end
