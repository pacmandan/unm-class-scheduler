defmodule UnmClassScheduler.Schema.HasConflicts do
  @moduledoc """
  Behavior module that provides the `:conflict_target` value passed to `Repo.insert()` or `Repo.insert_all()`.

  This function is primarily used during the XML import in order to simplify the process.
  """
  @callback conflict_keys() :: list(atom()) | atom()
end
