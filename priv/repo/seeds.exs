# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     UnmClassScheduler.Repo.insert!(%UnmClassScheduler.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias UnmClassScheduler.Repo
alias UnmClassScheduler.Catalog.{
  PartOfTerm,
  Status,
}

IO.puts("Inserting Parts of Term...")
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
|> Stream.each(&Repo.insert!/1)
|> Stream.run()

IO.puts("Inserting Statuses...")
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
|> Stream.each(&Repo.insert!/1)
|> Stream.run()

IO.puts("Inserting Delivery Types...")
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
  "WR" => "Writing",
  "WS" => "Workshop",
}
# TODO: Insert these

IO.puts("Inserting Instrucitonal Methods...")
%{
  "ENH" => "Web Enhanced",
  "HYB" => "Hybrid",
  "" => "",
  "MOPS" => "Accelerated Online Programs",
  "OL" => "Open Learning",
  "ONL" => "Online",
}
# TODO: Insert these
# FIXME: What do we do about the ones with empty string?

# UnmClassScheduler.testload()
UnmClassScheduler.ScheduleParser.Updater.load_from_file("./xmls/current.xml")
