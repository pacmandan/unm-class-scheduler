defmodule UnmClassScheduler.TestSeeds do
  @moduledoc """
  Seeds for test cases. Should be called during setup of tests using DataCase.
  """
  alias UnmClassScheduler.Catalog.Status
  alias UnmClassScheduler.Catalog.DeliveryType
  alias UnmClassScheduler.Catalog.InstructionalMethod
  alias UnmClassScheduler.Catalog.PartOfTerm

  alias UnmClassScheduler.Catalog.Semester
  alias UnmClassScheduler.Catalog.Campus
  alias UnmClassScheduler.Repo

  def seed_statuses() do
    %{
      "A" => "Active",
      "C" => "Cancelled",
      "I" => "Inactive",
      "M" => "Cancelled w/Message",
      "R" => "Reserved",
      "S" => "Cancelled/Rescheduled",
      "T" => "Cancelled/Reschedule w/Message",
    }
    |> Stream.map(fn {code, name} -> %Status{code: code, name: name} end)
    |> Enum.each(&Repo.insert!/1)
  end

  def seed_part_of_terms() do
    %{
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
    |> Stream.map(fn {code, name} -> %PartOfTerm{code: code, name: name} end)
    |> Enum.each(&Repo.insert!/1)
  end

  def seed_delivery_types() do
    %{
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
    |> Stream.map(fn {code, name} -> %DeliveryType{code: code, name: name} end)
    |> Enum.each(&Repo.insert!/1)
  end

  def seed_instructional_methods() do
    %{
      "ENH" => "Web Enhanced",
      "HYB" => "Hybrid",
      "MOPS" => "Accelerated Online Programs",
      "OL" => "Open Learning",
      "ONL" => "Online",
    }
    |> Stream.map(fn {code, name} -> %InstructionalMethod{code: code, name: name} end)
    |> Enum.each(&Repo.insert!/1)
  end

  def seed_semesters() do
    %{
      "202310" => "Spring 2023",
      "202360" => "Summer 2023",
      "202380" => "Fall 2023",
    }
    |> Stream.map(fn {code, name} -> %Semester{code: code, name: name} end)
    |> Enum.each(&Repo.insert!/1)
  end

  def seed_campuses() do
    %{
      "ABQ" => "Albuquerque/Main",
      "GA" => "Gallup",
      "LA" => "Los Alamos",
    }
    |> Stream.map(fn {code, name} -> %Campus{code: code, name: name} end)
    |> Enum.each(&Repo.insert!/1)
  end
end
