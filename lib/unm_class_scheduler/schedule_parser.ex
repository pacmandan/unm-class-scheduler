defmodule UnmClassScheduler.ScheduleParser do
  # TODO: Rename this & Updater
  @moduledoc """
  """
  alias UnmClassScheduler.ScheduleParser.Updater
  alias UnmClassScheduler.ScheduleParser.XMLExtractor
  alias UnmClassScheduler.ScheduleParser.FileDownloader

  # @urls [
  #   "https://xmlschedule.unm.edu/current.xml",
  #   "https://xmlschedule.unm.edu/next1.xml",
  #   "https://xmlschedule.unm.edu/next2.xml",
  # ]

  @spec download_and_run(list(String.t())) :: :ok
  def download_and_run(urls) do
    {:ok, files} = get_downloader().download_all(urls)

    load_from_files(files)

    get_downloader().cleanup_files(files)

    :ok
  end

  @spec load_from_files(list(String.t())) :: any()
  def load_from_files(files) do
    files
    |> XMLExtractor.extract_from()
    |> Updater.mass_insert()
  end

  @spec get_downloader() :: module()
  defp get_downloader() do
    Application.get_env(:unm_class_scheduler, :file_downloader, FileDownloader)
  end
end
