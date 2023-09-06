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

if Application.get_env(:unm_class_scheduler, :env) in [:dev] do
  UnmClassScheduler.DBUpdater.load_from_files([
    "./xmls/current.xml",
    "./xmls/next1.xml",
    "./xmls/next2.xml",
  ])
end
