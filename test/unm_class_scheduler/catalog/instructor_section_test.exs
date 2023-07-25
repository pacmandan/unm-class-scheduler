defmodule UnmClassScheduler.Catalog.InstructorSectionTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.InstructorSection
  alias UnmClassScheduler.Catalog.Instructor
  alias UnmClassScheduler.Catalog.Section

  doctest UnmClassScheduler.Catalog.InstructorSection

  defp setup_instructor(context) do
    params = Map.take(context, [:first, :last, :middle_initial, :email])
    |> Enum.reject(fn {_, k} -> is_nil(k) end)
    |> Enum.into(%{})

    instructor = %Instructor{uuid: context.instructor_uuid}

    {:ok, instructor: Map.merge(instructor, params)}
  end

  defp setup_section(context) do
    params = Map.take(context, [:crn])
    |> Enum.reject(fn {_, k} -> is_nil(k) end)
    |> Enum.into(%{})

    section = %Section{uuid: context.section_uuid}

    {:ok, section: Map.merge(section, params)}
  end

  describe "validate_data/2" do
    @describetag first: "Testy"
    @describetag middle_initial: "M"
    @describetag last: "McTesterson"
    @describetag email: "test@testmail.com"
    @describetag instructor_uuid: "IN12345"

    @describetag crn: "CRN50001"
    @describetag section_uuid: "SEC12345"

    @describetag primary: true

    setup [:setup_instructor, :setup_section]

    @tag section_uuid: nil
    test "when missing section uuid", %{primary: primary, instructor: instructor, section: section} do
      assert InstructorSection.validate_data(%{primary: primary}, instructor: instructor, section: section) ==
        {:error, [{:section_uuid, {"can't be blank", [validation: :required]}}]}
    end

    @tag instructor_uuid: nil
    test "when missing instructor uuid", %{primary: primary, instructor: instructor, section: section} do
      assert InstructorSection.validate_data(%{primary: primary}, instructor: instructor, section: section) ==
        {:error, [{:instructor_uuid, {"can't be blank", [validation: :required]}}]}
    end

    @tag primary: nil
    test "when missing primary", %{instructor: instructor, section: section} do
      assert InstructorSection.validate_data(%{}, instructor: instructor, section: section) ==
        {:error, [{:primary, {"can't be blank", [validation: :required]}}]}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(InstructorSection.serialize(nil))
    end

    test "when given Ecto.Association.NotLoaded" do
      assert is_nil(InstructorSection.serialize(%Ecto.Association.NotLoaded{}))
    end
  end
end
