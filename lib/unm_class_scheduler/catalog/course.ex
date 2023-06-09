defmodule UnmClassScheduler.Catalog.Course do
  use UnmClassScheduler.Schema

  alias UnmClassScheduler.Catalog.{
    Subject,
    Section
  }

  import Ecto.Changeset

  schema "courses" do
    field :number, :string
    field :title, :string

    belongs_to :subject, Subject, references: :uuid, foreign_key: :subject_uuid
    has_many :sections, Section, references: :uuid, foreign_key: :course_uuid

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:number, :title])
    |> validate_required([:number, :title, :subject_uuid])
    |> unique_constraint([:number, :subject_uuid])
  end
end
