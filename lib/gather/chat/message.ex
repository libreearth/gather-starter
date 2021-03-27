defmodule Gather.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gather.{Accounts, Chat}

  schema "messages" do
    field :content, :string
    field :author, :string, virtual: true

    belongs_to :user, Accounts.User
    belongs_to :conversation, Chat.Conversation

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
