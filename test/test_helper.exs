ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(UnmClassScheduler.Repo, :manual)

Mox.defmock(UnmClassScheduler.ScheduleParser.FileDownloaderMock, for: UnmClassScheduler.ScheduleParser.FileDownloader)
