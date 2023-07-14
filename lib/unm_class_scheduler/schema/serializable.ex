defmodule UnmClassScheduler.Schema.Serializable do
  @callback serialize(schema :: Ecto.Schema.t()) :: map()
end
