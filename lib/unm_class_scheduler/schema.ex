defmodule UnmClassScheduler.Schema do
  defmacro __using__(opts \\ []) do
    quote do
      use Ecto.Schema
      @primary_key {:uuid, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @derive {Phoenix.Param, key: :uuid}

      def conflict_keys() do
        unquote(opts[:conflict_keys])
      end
    end
  end
end
