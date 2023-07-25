defmodule UnmClassScheduler.Catalog.SectionTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.Section
  alias UnmClassScheduler.Catalog.Course
  alias UnmClassScheduler.Catalog.Semester
  alias UnmClassScheduler.Catalog.Campus
  alias UnmClassScheduler.Catalog.PartOfTerm
  alias UnmClassScheduler.Catalog.Status
  alias UnmClassScheduler.Catalog.DeliveryType
  alias UnmClassScheduler.Catalog.InstructionalMethod

  doctest UnmClassScheduler.Catalog.Section

  defp setup_params(context) do
    params = Map.take(context, [
      :crn,
      :number,
      :title,
      :enrollment,
      :enrollment_max,
      :waitlist,
      :waitlist_max,
      :credits,
      :credits_min,
      :credits_max,
      :fees,
      :text,
    ])
    |> Enum.reject(fn {_, k} -> is_nil(k) end)
    |> Enum.into(%{})
    {:ok, params: params}
  end

  defp setup_associations(context) do
    associations = %{
      course: %Course{uuid: context.course_uuid},
      semester: %Semester{uuid: context.semester_uuid},
      campus: %Campus{uuid: context.campus_uuid},
      part_of_term: %PartOfTerm{uuid: context.part_of_term_uuid},
      status: %Status{uuid: context.status_uuid},
      delivery_type: %DeliveryType{uuid: context.delivery_type_uuid},
      instructional_method: %InstructionalMethod{uuid: context.instructional_method_uuid},
    }
    {:ok, associations: associations}
  end

  describe "validate_data/2" do
    @describetag crn: "500001"
    @describetag number: "0001"

    @describetag course_uuid: "CO12345"
    @describetag semester_uuid: "SEM12345"
    @describetag campus_uuid: "CAM12345"
    @describetag part_of_term_uuid: "PT12345"
    @describetag status_uuid: "ST12345"
    @describetag delivery_type_uuid: "DT12345"
    @describetag instructional_method_uuid: "IM12345"

    setup [:setup_params, :setup_associations]

    @tag title: "Example Title"
    @tag enrollment: 0
    @tag enrollment_max: 10
    @tag waitlist: 0
    @tag waitlist_max: 10
    @tag credits: "1 TO 6"
    @tag credits_min: 1
    @tag credits_max: 6
    @tag fees: 30.5
    @tag text: "Section Text"
    test "when given full valid params", %{params: params, associations: associations} do
      expected_result = %{
        crn: "500001",
        number: "0001",
        title: "Example Title",
        enrollment: 0,
        enrollment_max: 10,
        waitlist: 0,
        waitlist_max: 10,
        credits: "1 TO 6",
        credits_min: 1,
        credits_max: 6,
        fees: 30.5,
        text: "Section Text",
        course_uuid: "CO12345",
        semester_uuid: "SEM12345",
        campus_uuid: "CAM12345",
        part_of_term_uuid: "PT12345",
        status_uuid: "ST12345",
        delivery_type_uuid: "DT12345",
        instructional_method_uuid: "IM12345",
      }
      assert Section.validate_data(params, associations) ==
        {:ok, expected_result}
    end

    @tag crn: nil
    test "when missing crn", %{params: params, associations: associations} do
      assert Section.validate_data(params, associations) ==
        {:error, [{:crn, {"can't be blank", [validation: :required]}}]}
    end

    @tag number: nil
    test "when missing number", %{params: params, associations: associations} do
      assert Section.validate_data(params, associations) ==
        {:error, [{:number, {"can't be blank", [validation: :required]}}]}
    end

    @tag course_uuid: nil
    test "when missing course uuid", %{params: params, associations: associations} do
      assert Section.validate_data(params, associations) ==
        {:error, [{:course_uuid, {"can't be blank", [validation: :required]}}]}
    end

    test "when missing course", %{params: params, associations: associations} do
      assert Section.validate_data(params, Map.delete(associations, :course)) ==
        {:error, [{:course_uuid, {"can't be blank", [validation: :required]}}]}
    end

    @tag semester_uuid: nil
    test "when missing semester uuid", %{params: params, associations: associations} do
      assert Section.validate_data(params, associations) ==
        {:error, [{:semester_uuid, {"can't be blank", [validation: :required]}}]}
    end

    test "when missing semester", %{params: params, associations: associations} do
      assert Section.validate_data(params, Map.delete(associations, :semester)) ==
        {:error, [{:semester_uuid, {"can't be blank", [validation: :required]}}]}
    end

    @tag campus_uuid: nil
    test "when missing campus uuid", %{params: params, associations: associations} do
      assert Section.validate_data(params, associations) ==
        {:error, [{:campus_uuid, {"can't be blank", [validation: :required]}}]}
    end

    test "when missing campus", %{params: params, associations: associations} do
      assert Section.validate_data(params, Map.delete(associations, :campus)) ==
        {:error, [{:campus_uuid, {"can't be blank", [validation: :required]}}]}
    end
  end
end
