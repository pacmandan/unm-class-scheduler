defmodule UnmClassScheduler.Fixtures do
  @moduledoc """
  This is a test module intended to put fixtures into the database.

  It is NOT used in the updater, since it is very inefficient and has no
  protections against invalid parameters. ONLY USE IN TESTING!
  """

  alias UnmClassScheduler.Repo

  @spec build(list(Ecto.Schema.t()), (Ecto.Schema.t() -> any())) :: %{any() => Ecto.Schema.t()}
  def build(params, key_fn \\ &code_key/1) do
    Enum.map(params, &Repo.insert/1)
    |> Enum.map(fn {:ok, d} -> d end)
    |> Enum.map(fn d -> {key_fn.(d), d} end)
    |> Enum.into(%{})
  end

  @spec build_no_key(Ecto.Schema.t()) :: list(Ecto.Schema.t())
  def build_no_key(params) do
    Enum.map(params, &Repo.insert/1)
  end

  @spec code_key(Ecto.Schema.t()) :: String.t()
  def code_key(data), do: data.code
end
