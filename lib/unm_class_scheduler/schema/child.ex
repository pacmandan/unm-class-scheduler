defmodule UnmClassScheduler.Schema.Child do
  @callback parent_module() :: module()
  @callback parent_key() :: atom()
  @callback get_parent(schema :: struct()) :: struct()
end
