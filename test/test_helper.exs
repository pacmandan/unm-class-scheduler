ExUnit.start()
Faker.start()
{:ok, _} = Application.ensure_all_started(:ex_machina)
Ecto.Adapters.SQL.Sandbox.mode(UnmClassScheduler.Repo, :manual)

Mox.defmock(UnmClassScheduler.DBUpdater.MockFileDownloader, for: UnmClassScheduler.DBUpdater.FileDownloader)
