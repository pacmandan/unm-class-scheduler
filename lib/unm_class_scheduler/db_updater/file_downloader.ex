defmodule UnmClassScheduler.DBUpdater.FileDownloader do
  @moduledoc """
  Module with functions in charge of downloading and cleaning up schedule files.

  Mockable, since this interacts with external systems.
  """
  @callback download_all(list(String.t())) :: {:ok, list(String.t())}
  @callback cleanup_files(list(String.t())) :: :ok

  @behaviour __MODULE__

  @impl true
  @spec download_all(list(String.t())) :: {:ok, list(String.t())}
  def download_all(urls) do
    dir = get_tmp_dir()
    files = Enum.map(urls, fn url ->
      with filename <- Path.basename(url),
        file_path <- Path.join(dir, filename)
      do
        # TODO: Handle failure
        {:ok, _} = download_to_file(url, file_path)
        file_path
      end
    end)
    {:ok, files}
  end

  @spec download_to_file(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  defp download_to_file(url, file_path) do
    :httpc.request(:get, {url, []}, [], [stream: String.to_charlist(file_path)])
  end

  defp get_tmp_dir() do
    System.tmp_dir!()
  end

  @impl true
  @spec cleanup_files(list(String.t())) :: :ok
  def cleanup_files(files) do
    Enum.each(files, fn file -> File.rm!(file) end)
    :ok
  end
end
