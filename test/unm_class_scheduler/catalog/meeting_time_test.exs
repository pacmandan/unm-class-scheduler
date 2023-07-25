defmodule UnmClassScheduler.Catalog.MeetingTimeTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Catalog.MeetingTime
  alias UnmClassScheduler.Catalog.Section
  alias UnmClassScheduler.Catalog.Building

  doctest UnmClassScheduler.Catalog.MeetingTime

  defp setup_meeting_time(context) do
    keys = [
      :sunday,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday,
      :start_date,
      :end_date,
      :start_time,
      :end_time,
      :room,
      :index,
    ]
    params = Map.take(context, keys)
    |> Enum.reject(fn {_, k} -> is_nil(k) end)
    |> Enum.into(%{})

    {:ok, params: params}
  end

  defp setup_section(context) do
    {:ok, section: %Section{uuid: context.section_uuid}}
  end

  defp setup_building(context) do
    {:ok, building: %Building{uuid: context.building_uuid}}
  end

  describe "validate_data/2" do
    @describetag sunday: false
    @describetag monday: false
    @describetag tuesday: false
    @describetag wednesday: false
    @describetag thursday: false
    @describetag friday: false
    @describetag saturday: false
    @describetag start_date: ~D[2023-06-05]
    @describetag end_date: ~D[2024-06-05]
    @describetag start_time: ~T[10:00:00]
    @describetag end_time: ~T[11:00:00]
    @describetag room: "100"
    @describetag index: 0

    @describetag section_uuid: "SEC12345"
    @describetag building_uuid: "BLDG12345"

    setup [:setup_meeting_time, :setup_section, :setup_building]

    test "with valid params", %{params: params, building: building, section: section} do
      expected_result = %{
        sunday: false,
        monday: false,
        tuesday: false,
        wednesday: false,
        thursday: false,
        friday: false,
        saturday: false,
        start_date: ~D[2023-06-05],
        end_date: ~D[2024-06-05],
        start_time: ~T[10:00:00],
        end_time: ~T[11:00:00],
        room: "100",
        index: 0,
        section_uuid: "SEC12345",
        building_uuid: "BLDG12345",
      }
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:ok, expected_result}
    end

    @tag monday: nil
    test "with a missing weekday", %{params: params, building: building, section: section} do
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:error, [{:monday, {"can't be blank", [validation: :required]}}]}
    end

    @tag start_date: nil
    test "with missing start date", %{params: params, building: building, section: section} do
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:error, [{:start_date, {"can't be blank", [validation: :required]}}]}
    end

    @tag end_date: nil
    test "with missing end date", %{params: params, building: building, section: section} do
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:error, [{:end_date, {"can't be blank", [validation: :required]}}]}
    end

    @tag start_time: nil
    test "with missing start time", %{params: params, building: building, section: section} do
      expected_result = %{
        sunday: false,
        monday: false,
        tuesday: false,
        wednesday: false,
        thursday: false,
        friday: false,
        saturday: false,
        start_date: ~D[2023-06-05],
        end_date: ~D[2024-06-05],
        end_time: ~T[11:00:00],
        room: "100",
        index: 0,
        section_uuid: "SEC12345",
        building_uuid: "BLDG12345",
      }
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:ok, expected_result}
    end

    @tag end_time: nil
    test "with missing end time", %{params: params, building: building, section: section} do
      expected_result = %{
        sunday: false,
        monday: false,
        tuesday: false,
        wednesday: false,
        thursday: false,
        friday: false,
        saturday: false,
        start_date: ~D[2023-06-05],
        end_date: ~D[2024-06-05],
        start_time: ~T[10:00:00],
        room: "100",
        index: 0,
        section_uuid: "SEC12345",
        building_uuid: "BLDG12345",
      }
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:ok, expected_result}
    end

    @tag room: nil
    test "with missing room", %{params: params, building: building, section: section} do
      expected_result = %{
        sunday: false,
        monday: false,
        tuesday: false,
        wednesday: false,
        thursday: false,
        friday: false,
        saturday: false,
        start_date: ~D[2023-06-05],
        end_date: ~D[2024-06-05],
        start_time: ~T[10:00:00],
        end_time: ~T[11:00:00],
        index: 0,
        section_uuid: "SEC12345",
        building_uuid: "BLDG12345",
      }
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:ok, expected_result}
    end

    @tag index: nil
    test "with missing index", %{params: params, building: building, section: section} do
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:error, [{:index, {"can't be blank", [validation: :required]}}]}
    end

    @tag section_uuid: nil
    test "with missing section uuid", %{params: params, building: building, section: section} do
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:error, [{:section_uuid, {"can't be blank", [validation: :required]}}]}
    end

    @tag building_uuid: nil
    test "with missing building uuid", %{params: params, building: building, section: section} do
      expected_result = %{
        sunday: false,
        monday: false,
        tuesday: false,
        wednesday: false,
        thursday: false,
        friday: false,
        saturday: false,
        start_date: ~D[2023-06-05],
        end_date: ~D[2024-06-05],
        start_time: ~T[10:00:00],
        end_time: ~T[11:00:00],
        room: "100",
        index: 0,
        section_uuid: "SEC12345",
      }
      assert MeetingTime.validate_data(params, building: building, section: section) ==
        {:ok, expected_result}
    end

    test "with missing section", %{params: params, building: building} do
      assert MeetingTime.validate_data(params, building: building, section: nil) ==
        {:error, [{:section_uuid, {"can't be blank", [validation: :required]}}]}
    end

    test "with missing building", %{params: params, section: section} do
      expected_result = %{
        sunday: false,
        monday: false,
        tuesday: false,
        wednesday: false,
        thursday: false,
        friday: false,
        saturday: false,
        start_date: ~D[2023-06-05],
        end_date: ~D[2024-06-05],
        start_time: ~T[10:00:00],
        end_time: ~T[11:00:00],
        room: "100",
        index: 0,
        section_uuid: "SEC12345",
      }
      assert MeetingTime.validate_data(params, building: nil, section: section) ==
        {:ok, expected_result}
    end
  end

  describe "serialize/1" do
    test "when given nil" do
      assert is_nil(MeetingTime.serialize(nil))
    end

    test "when given Ecto.Association.NotLoaded" do
      assert is_nil(MeetingTime.serialize(%Ecto.Association.NotLoaded{}))
    end
  end
end
