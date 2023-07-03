defmodule UnmClassScheduler.Schema.Validatable do
  @moduledoc """
  Behavior that validates a map of the schema data without creating a full Schema.
  This allows use to use Changeset validation on bulk inserts, since we can only push lists of maps to
  `UnmClassScheduler.Repo.insert_all()` and not a list of Changesets or Schemas.
  """
  @callback validate_data(params :: map(), associations :: keyword(struct())) :: {:ok, map()} | {:error, [{atom(), Ecto.Changeset.error()}]}
end
