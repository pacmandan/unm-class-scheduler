defmodule UnmClassScheduler.Schema.Child do
  @callback parent_module() :: term()

  defmacro __using__([parent: parent]) do
    quote do
      @behaviour UnmClassScheduler.Schema.Child
      def parent_module() do
        unquote(parent)
      end

      defoverridable parent_module: 0
    end
  end
end
