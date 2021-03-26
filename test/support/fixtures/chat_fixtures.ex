defmodule Gather.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gather.Chat` context.
  """

  alias Gather.{AccountsFixtures, Chat}

  def conversation_fixture(attrs \\ %{}) do
    {:ok, conversation} =
      attrs
      |> Enum.into(%{
        title: "title"
      })
      |> Chat.create_conversation()

    conversation
  end

  def message_fixture(attrs \\ %{}) do
    user = Map.get_lazy(attrs, :user, &AccountsFixtures.user_fixture/0)
    conversation = Map.get_lazy(attrs, :conversation, &conversation_fixture/0)

    attrs =
      Enum.into(attrs, %{
        content: "content"
      })

    {:ok, message} = Chat.create_message(user, conversation, attrs)

    message
  end
end
