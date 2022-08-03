defmodule Uberphoenix.Examples do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    embeds_many :examples, Example do
      field :example_id, :string
      field :name, :string
      field :amount, :float
      field :is_active, :boolean
    end
  end

  @doc false
  def changeset(examples, attrs) do
    examples
    |> cast(attrs, [])
    |> cast_embed(:examples, required: true, with: &example_changeset/2)
  end

  def example_changeset(example, attrs \\ %{}) do
    example
    |> cast(attrs, [:example_id, :name, :amount, :is_active])
    |> validate_required([:example_id, :name, :amount, :is_active])
  end
end
