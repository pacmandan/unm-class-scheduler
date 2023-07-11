defmodule UnmClassScheduler.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:uuid, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @derive {Phoenix.Param, key: :uuid}

      # Implement Access behavior for all Schemas
      # @behaviour Access
      # defdelegate get(v, key, default), to: Map
      # defdelegate fetch(v, key), to: Map
      # defdelegate get_and_update(v, key, func), to: Map
      # # Non-destructive pop implementation
      # @impl true
      # def pop(v, key), do: {v[key], v}
    end
  end
end
