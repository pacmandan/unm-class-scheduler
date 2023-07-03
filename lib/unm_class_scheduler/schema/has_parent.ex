defmodule UnmClassScheduler.Schema.HasParent do
  @moduledoc """
  Behavior applied to schemas with a single parent association.

  These functions are primarily used during the XML import in order to simplify the process
  for simple 1-parent Schemas.
  """
  @callback parent_module() :: module()
  @callback parent_key() :: atom()
  @callback get_parent(schema :: struct()) :: struct()
end
