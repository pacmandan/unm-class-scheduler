defmodule UnmClassScheduler.Schema.Parent do
  @callback new_child(struct()) :: term()

  defmacro __using__([child: assoc_key]) do
    quote do
      @behaviour UnmClassScheduler.Schema.Parent
      def new_child(parent) do
        Ecto.build_assoc(parent, unquote(assoc_key))
      end

      defoverridable new_child: 1
    end
  end
end
