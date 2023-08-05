defmodule Mix.Tasks.Frontend.Package do
  @moduledoc "Compiles and packages UNM React frontend for production"
  @shortdoc "Package UNM React frontend"

  use Mix.Task

  require Logger

  @public_path "./priv/static/webapp"

  @impl true
  def run(_) do
    Logger.info("Installing NPM Pacakges...")

    System.cmd("npm", ["install", "--quiet"], cd: "./frontend")

    Logger.info("Compiling React frontend")
    System.cmd("npm", ["run", "build"], cd: "./frontend")

    Logger.info("Moving dist folder to Phoenix at #{@public_path}")
    # First clean up any stale files from previous builds if any
    System.cmd("rm", ["-rf", @public_path])
    System.cmd("cp", ["-R", "./frontend/dist", @public_path])

    Logger.info("React frontend ready.")
  end
end
