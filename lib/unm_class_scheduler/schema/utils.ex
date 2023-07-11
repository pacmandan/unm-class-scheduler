defmodule UnmClassScheduler.Schema.Utils do
  @moduledoc """
  Utility module with types and functions used in Catalog Schema files.
  """

  @typedoc """
  Return value for `apply_changeset_if_valid/1` as well as every
  `validate_data/2` function in every schema.
  """
  @type maybe_valid_changes ::
    {:ok, map() | Ecto.Schema.t()} |
    {:error, [{atom(), Ecto.Changeset.error()}]}

  @doc """
  If a changeset is valid, apply the changes and return the map or Schema with the changes applied.
  Otherwise, return the error list from the changeset.
  """
  @spec apply_changeset_if_valid(Ecto.Changeset.t()) :: maybe_valid_changes()
  def apply_changeset_if_valid(changeset) do
    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, changeset.errors}
    end
  end

  defp get_uuid(nil), do: nil
  defp get_uuid(maybe_has_uuid), do: maybe_has_uuid.uuid

  @doc """
  Applies the given associations to the changeset by applying their UUIDs to
  their associated keys.

  `%{department_uuid: %Department{uuid: "1234"}}` is applied as
  `%{department_uuid: "1234"}`

  This will also add a required validation for all associations.

  Any optional associations given are applied the same way, but will not have
  the same validation requirements. Any "nil" values here are simply rejected -
  this will not delete existing values.
  """
  @spec apply_association_uuids(Ecto.Changeset.t(), %{atom() => Ecto.Schema.t()}, %{atom() => Ecto.Schema.t() | nil}) :: Ecto.Changeset.t()
  def apply_association_uuids(changeset, associations, optional_associations \\ %{}) do
    uuids = associations
    |> Enum.map(fn {key, association} -> {key, get_uuid(association)} end)
    |> Enum.into(%{})

    optional_uuids = optional_associations
    |> Enum.map(fn {key, association} -> {key, get_uuid(association)} end)
    |> Enum.reject(fn {_, u} -> is_nil(u) end)
    |> Enum.into(%{})

    changeset
    |> Ecto.Changeset.cast(uuids, Map.keys(associations))
    |> Ecto.Changeset.cast(optional_uuids, Map.keys(optional_associations))
    |> Ecto.Changeset.validate_required(Map.keys(associations))
  end
end
