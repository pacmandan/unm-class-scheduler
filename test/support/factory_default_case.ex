defmodule UnmClassScheduler.FactoryDefaultCase do
  @moduledoc """
  Similar to DataCase, but forces some specifics:
  * Tests MUST be listed as async: false
  * The database connection is shared between all tests.
  * A "default" set of records is injected into the database before testing starts.

  This is primarily a case useful for search and query tests that span
  every table in the application, which would be inconvinient to insert between
  every test.

  It is recommended to ONLY use this case for functions that read data rather than write it.
  If databse insertions are also used, be aware that overlaps between tests may happen.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias UnmClassScheduler.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import UnmClassScheduler.FactoryDefaultCase
    end
  end

  setup_all do
    UnmClassScheduler.FactoryDefaultCase.setup_sandbox()
    UnmClassScheduler.Factory.factory_default()

    :ok
  end

  @doc """
  Sets up the sandbox.
  """
  def setup_sandbox() do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(UnmClassScheduler.Repo, shared: true)
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
