defmodule UnmClassScheduler.DBUpdater.StaticTables do
  alias UnmClassScheduler.Catalog.PartOfTerm
  alias UnmClassScheduler.Catalog.Status
  alias UnmClassScheduler.Catalog.DeliveryType
  alias UnmClassScheduler.Catalog.InstructionalMethod

  require Logger

  @parts_of_term %{
    "1" => "Full Term",
    "1H" => "First Half Term",
    "2H" => "Second Half Term",
    "3Q" => "Three-Quarter Term",
    "C" => "Combined Sessions",
    "INT" => "Late Starting Courses",
    "LAW" => "Law Term",
    "M01" => "MD Program - Block 1",
    "M02" => "MD Program - Block 2",
    "M03" => "MD Program - Block 3",
    "M04" => "MD Program - Block 4",
    "M05" => "MD Program - Block 5",
    "M06" => "MD Program - Block 6",
    "M07" => "MD Program - Block 7",
    "M08" => "MD Program - Block 8",
    "M09" => "MD Program - Block 9",
    "M10" => "MD Program - Block 10",
    "M11" => "MD Program - Block 11",
    "M12" => "MD Program - Block 12",
    "M13" => "MD Program - Block 13",
    "M14" => "MD Program - Block 14",
    "N1H" => "Nursing First Half Term",
    "N2H" => "Nursing Second Half Term",
    "NF" => "Nursing Full Term",
    "OL" => "Open Learning",
    "PBM" => "MS-BIOM-CR Program",
    "REM" => "Remedial Courses",
    "SSP" => "Special Student Programs",
  }

  @statuses %{
    "A" => "Active",
    "C" => "Cancelled",
    "I" => "Inactive",
    "M" => "Cancelled w/Message",
    "R" => "Reserved",
    "S" => "Cancelled/Rescheduled",
    "T" => "Cancelled/Reschedule w/Message",
  }

  @delivery_types %{
    "AM" => "Applied Music",
    "CL" => "Clinical Clerkship",
    "CM" => "Chamber Music",
    "CO" => "Cooperative Education",
    "DS" => "Dissertation",
    "EX" => "Practice Experience",
    "IN" => "Independent Study",
    "LB" => "Laboratory",
    "LC" => "Lecture",
    "LL" => "Combined Lecture/Lab",
    "LLE" => "*Lecture/Lab Web Enhanced",
    "LP" => "Lecture/Practice Experience",
    "ME" => "Major Music Ensemble",
    "MP" => "Music Pedagogy",
    "MR" => "Music Repertory",
    "PD" => "Prof Paper/Project/Design Proj",
    "RC" => "Recitation",
    "SM" => "Seminar",
    "ST" => "Studio",
    "TD" => "*Thesis/Dissertation",
    "TH" => "Thesis",
    "TP" => "Topics",
    "TPE" => "Topics Web Enhanced",
    "WR" => "Writing",
    "WS" => "Workshop",
  }

  @instructional_methods %{
    "ENH" => "Web Enhanced",
    "HYB" => "Hybrid",
    "MOPS" => "Accelerated Online Programs",
    "OL" => "Open Learning",
    "ONL" => "Online",
  }

  @schema_mapping [
    {PartOfTerm, @parts_of_term},
    {Status, @statuses},
    {DeliveryType, @delivery_types},
    {InstructionalMethod, @instructional_methods}
  ]

  def ensure_all_updated(repo) do
    placeholders = %{now: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)}

    @schema_mapping
    |> Enum.map(fn {schema, list} ->
      list
      |> Enum.map(&to_schema_map/1)
      |> then(&(repo.insert_all(
        schema,
        &1,
        on_conflict: {:replace_all_except, [:inserted_at, :uuid]},
        conflict_target: :code,
        returning: true,
        placeholders: placeholders
      )))
      |> elem(1)
      |> tap(fn records -> Logger.info("Inserted #{length(records)} records to #{schema}") end)
      |> Enum.map(fn record -> {record.code, record} end)
      |> Map.new()
      |> then(&({schema, &1}))
    end)
    |> Map.new()
    |> then(&({:ok, &1}))
  end

  defp to_schema_map({key, value}) do
    %{
      code: key,
      name: value,
      inserted_at: {:placeholder, :now},
      updated_at: {:placeholder, :now},
    }
  end
end
