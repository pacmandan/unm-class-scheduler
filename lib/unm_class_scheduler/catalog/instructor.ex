defmodule UnmClassScheduler.Catalog.Instructor do
  @behaviour UnmClassScheduler.Schema.Validatable
  @behaviour UnmClassScheduler.Schema.HasConflicts

  use UnmClassScheduler.Schema

  import Ecto.Changeset

  schema "instructors" do
    field :first, :string
    field :last, :string
    field :middle_initial, :string
    field :email, :string

    timestamps()
  end

  @impl true
  def validate_data(params, _associations \\ []) do
    # TODO: Go through schemas again and clean up the validate functions a bit.
    # Generalize types and fields maybe?
    # Fix whitespace, etc
    data = %{}
    types = %{first: :string, last: :string, middle_initial: :string, email: :string}
    cs = {data, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:first, :last, :email])

    if cs.valid? do
      {:ok, apply_changes(cs)}
    else
      {:error, cs.errors}
    end
  end

  # Emails are not unique - some instructors are listed as "No UNM email address"
  @impl true
  def conflict_keys(), do: [:email, :first, :last]
end
