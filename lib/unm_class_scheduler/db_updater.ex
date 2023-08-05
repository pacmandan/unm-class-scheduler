defmodule UnmClassScheduler.DBUpdater do
  @moduledoc """
  Primary module called by updater processes.
  """
  alias UnmClassScheduler.DBUpdater.Insert
  alias UnmClassScheduler.DBUpdater.XMLExtractor
  alias UnmClassScheduler.DBUpdater.FileDownloader

  require Logger

  @default_urls [
    "https://xmlschedule.unm.edu/current.xml",
    "https://xmlschedule.unm.edu/next1.xml",
    "https://xmlschedule.unm.edu/next2.xml",
  ]

  @spec download_and_run() :: :ok
  def download_and_run() do
    download_and_run(@default_urls)
  end

  @spec download_and_run(list(String.t())) :: :ok
  def download_and_run(urls) do
    :ok = prepare!()

    {:ok, files} = get_downloader().download_all(urls)

    load_from_files(files)

    get_downloader().cleanup_files(files)

    :ok
  end

  @spec load_from_files(list(String.t())) :: any()
  def load_from_files(files) do
    files
    |> XMLExtractor.extract_from()
    |> Insert.mass_insert()
  end

  @spec get_downloader() :: module()
  defp get_downloader() do
    Application.get_env(:unm_class_scheduler, :file_downloader, FileDownloader)
  end

  defp prepare!() do
    Application.ensure_all_started(:unm_class_scheduler)
    # Double-check the connection before we try downloading stuff.
    Ecto.Adapters.SQL.query!(UnmClassScheduler.Repo, "SELECT 1")
    :ok
  end
end
