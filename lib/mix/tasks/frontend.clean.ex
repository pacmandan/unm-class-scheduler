defmodule Mix.Tasks.Frontend.Clean do
  @moduledoc "Removes built UNM React frontend"
  @shortdoc "Clean UNM React frontend"

  use Mix.Task

  require Logger

  @public_path "./priv/static/webapp"

  @impl true
  def run(_) do
    Logger.info("Removing built package...")
    System.cmd("rm", ["-rf", @public_path])
  end
end
