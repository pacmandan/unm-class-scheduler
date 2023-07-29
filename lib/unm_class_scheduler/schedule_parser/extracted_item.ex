defmodule UnmClassScheduler.ScheduleParser.ExtractedItem do
  @moduledoc """
  Represents an abstract extracted record from an XML file.

  Records can have fields and associations.

  "Fields" are plain fields on the record - strings, integers, etc.
  Regular elements attached to the record itself.

  "Associations" are links to other records. They always need to take the form
  of `%{ModuleName => %{...}}` - Keys in associations are always the module
  name of the type of association, and values are a map of uniquely identifiable
  keys on the linked association.

  For example, a College association can be linked to a Department record like this:
  ```
  associations: %{College => %{code: "college code"}}
  ```
  """

  @type t() :: %__MODULE__{
    fields: fields(),
    associations: associations()
  }

  @type fields :: %{optional(atom()) => term()}
  @type associations :: %{optional(module()) => map()}

  defstruct [
    fields: %{},
    associations: %{},
  ]

  # @spec new(map(), map(), map()) :: __MODULE__.t()
  # def new(fields, field_transforms, associations \\ %{}) do
  #   extracted_fields = fields
  #   |> Map.new()
  #   |> Enum.reduce(%{}, fn {k, v}, acc ->
  #     case field_transforms[k] do
  #       nil -> acc
  #       tk -> Map.put(acc, tk, v)
  #     end
  #   end)
  #   %__MODULE__{fields: extracted_fields, associations: associations}
  # end

  @doc """
  Pushes or overwrites fields to the extracted item.

  ## Examples
      iex> ExtractedItem.push_fields(
      ...>   %ExtractedItem{fields: %{}, associations: %{}},
      ...>   %{code: "code1"}
      ...> )
      %ExtractedItem{fields: %{code: "code1"}, associations: %{}}

      iex> ExtractedItem.push_fields(
      ...>   %ExtractedItem{fields: %{code: "original_code"}, associations: %{}},
      ...>   %{code: "code1"}
      ...> )
      %ExtractedItem{fields: %{code: "code1"}, associations: %{}}

      iex> ExtractedItem.push_fields(
      ...>   %ExtractedItem{fields: %{extra: "value"}, associations: %{}},
      ...>   %{code: "code1"}
      ...> )
      %ExtractedItem{fields: %{code: "code1", extra: "value"}, associations: %{}}
  """
  @spec push_fields(__MODULE__.t(), fields()) :: __MODULE__.t()
  def push_fields(%__MODULE__{} = item, new_fields) do
    %__MODULE__{
      fields: item.fields |> Map.merge(new_fields),
      associations: item.associations,
    }
  end

  @doc """
  Pushes or orverwrites associations to the extracted item.

  ## Examples
      iex> ExtractedItem.push_associations(
      ...>   %ExtractedItem{fields: %{}, associations: %{}},
      ...>   %{Semester => %{code: "202310"}}
      ...> )
      %ExtractedItem{fields: %{}, associations: %{Semester => %{code: "202310"}}}

      iex> ExtractedItem.push_associations(
      ...>   %ExtractedItem{fields: %{}, associations: %{Semester => %{code: "202310"}}},
      ...>   %{Semester => %{code: "202360"}}
      ...> )
      %ExtractedItem{fields: %{}, associations: %{Semester => %{code: "202360"}}}

      iex> ExtractedItem.push_associations(
      ...>   %ExtractedItem{fields: %{}, associations: %{Semester => %{code: "202310"}}},
      ...>   %{Campus => %{code: "ABQ"}}
      ...> )
      %ExtractedItem{fields: %{}, associations: %{Semester => %{code: "202310"}, Campus => %{code: "ABQ"}}}
  """
  @spec push_associations(__MODULE__.t(), associations()) :: __MODULE__.t()
  def push_associations(%__MODULE__{} = item, new_assoc) do
    %__MODULE__{
      fields: item.fields,
      associations: item.associations |> Map.merge(new_assoc),
    }
  end
end
