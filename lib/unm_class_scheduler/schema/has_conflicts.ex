defmodule UnmClassScheduler.Schema.HasConflicts do
  @callback conflict_keys() :: list(atom()) | atom()
end
