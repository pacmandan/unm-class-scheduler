defmodule UnmClassScheduler.Utils.MapUtils do
  @moduledoc """
  General utils used for Maps.
  """

  @doc """
  Equivalent to .dig() in Ruby.
  Attempts to access a deeply nested value in a map.
  If any intermediate value is nil, the return is nil.

  ## Examples
      iex> MapUtils.maybe(%{a: "b"}, [:a])
      "b"

      iex> MapUtils.maybe(%{a: %{b: %{c: "d"}}}, [:a, :b, :c])
      "d"

      iex> MapUtils.maybe(%{a: %{b: %{c: "d"}}}, [:a, :e, :c])
      nil
  """
  @spec maybe(map(), [atom()]) :: any() | nil
  def maybe(nil, _keys), do: nil
  def maybe(val, []), do: val
  def maybe(map, [h|t]) do
    maybe(Map.get(map, h), t)
  end

  @doc """
  Alias of maybe/2

  ## Examples
      iex> MapUtils.dig(%{a: %{b: %{c: "d"}}}, [:a, :b, :c])
      "d"
  """
  @spec dig(map(), [atom()]) :: any() | nil
  defdelegate dig(map, keys), to: __MODULE__, as: :maybe
end
