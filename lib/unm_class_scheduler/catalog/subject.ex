defmodule UnmClassScheduler.Catalog.Subject do
  use UnmClassScheduler.Schema

  alias UnmClassScheduler.Catalog.{
    Department,
    Course
  }

  import Ecto.Changeset

  schema "subjects" do
    field :code, :string
    field :name, :string

    belongs_to :department, Department, references: :uuid, foreign_key: :department_uuid
    has_many :courses, Course, references: :uuid, foreign_key: :subject_uuid

    timestamps()
  end

  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end
end
