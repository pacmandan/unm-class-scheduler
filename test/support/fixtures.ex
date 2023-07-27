defmodule UnmClassScheduler.Fixtures do
  @moduledoc """
  This is a test module intended to put fixtures into the database.

  It is NOT used in the updater, since it is very inefficient and has no
  protections against invalid parameters. ONLY USE IN TESTING!
  """

  alias UnmClassScheduler.Repo

  def build(params, key_fn \\ &code_key/1) do
    Enum.map(params, &Repo.insert/1)
    |> Enum.map(fn d -> {key_fn.(d), d} end)
    |> Enum.into(%{})
  end

  def build_no_key(params) do
    Enum.map(params, &Repo.insert/1)
  end

  def code_key(data), do: data.code
end
