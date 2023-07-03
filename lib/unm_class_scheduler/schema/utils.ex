defmodule UnmClassScheduler.Schema.Utils do
  @moduledoc """
  Utility module with functions used in Catalog Schema files.
  """

  @doc """
  If a changeset is valid, apply the changes and return the map or Schema with the changes applied.
  Otherwise, return the error list from the changeset.
  """
  @spec apply_changeset_if_valid(Ecto.Changeset.t()) :: {:ok, map() | Ecto.Schema.t()} | {:error, [{atom(), Ecto.Changeset.error()}]}
  def apply_changeset_if_valid(changeset) do
    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, changeset.errors}
    end
  end

  # TODO: Check if each association is nil.
  # If it is, apply an error to the changeset.
  # Otherwise, cast the UUID into the given key.

  # Optional associations should be applied manually,
  # outside of this function.
  def apply_association_uuids(changeset, associations) do
    uuids = associations
    |> Enum.into(%{}, fn {key, association} -> {key, association.uuid} end)

    changeset |>
    Ecto.Changeset.cast(uuids, Map.keys(associations))
  end
end
