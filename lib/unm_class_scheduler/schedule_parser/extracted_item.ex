defmodule UnmClassScheduler.ScheduleParser.ExtractedItem do
  @type t() :: %__MODULE__{
    fields: map(),
    associations: map()
  }

  defstruct [
    fields: %{},
    associations: %{},
  ]

  @spec new(map(), map(), map()) :: __MODULE__.t()
  def new(fields, field_transforms, associations \\ %{}) do
    extracted_fields = fields
    |> Map.new()
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      case field_transforms[k] do
        nil -> acc
        tk -> Map.put(acc, tk, v)
      end
    end)
    %__MODULE__{fields: extracted_fields, associations: associations}
  end

  @spec push_fields(__MODULE__.t(), map) :: __MODULE__.t()
  def push_fields(%__MODULE__{} = item, new_fields) do
    %__MODULE__{
      fields: item.fields |> Map.merge(new_fields),
      associations: item.associations,
    }
  end

  @spec push_associations(__MODULE__.t(), map) :: __MODULE__.t()
  def push_associations(%__MODULE__{} = item, new_assoc) do
    %__MODULE__{
      fields: item.fields,
      associations: item.associations |> Map.merge(new_assoc),
    }
  end
end
