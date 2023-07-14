defmodule UnmClassSchedulerWeb.SearchController do
  use UnmClassSchedulerWeb, :controller

  def get(conn, _params) do
    json(conn, %{test: "TESTING"})
  end
end
