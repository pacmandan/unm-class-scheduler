defmodule UnmClassScheduler.Schema.Validatable do
  @callback validate_data(params :: map(), associations :: keyword(struct())) :: {:ok, map()} | {:error, term}
end
