defmodule Gather.ChatTest do
  use Gather.DataCase

  alias Gather.Chat

  import Gather.{AccountsFixtures, ChatFixtures}

  describe "conversations" do
    alias Gather.Chat.Conversation

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    test "list_conversations/0 returns all conversations" do
      conversation = conversation_fixture()
      assert Chat.list_conversations() == [conversation]
    end

    test "get_conversation!/1 returns the conversation with given id" do
      conversation = conversation_fixture()
      assert Chat.get_conversation!(conversation.id) == conversation
    end

    test "create_conversation/1 with valid data creates a conversation" do
      assert {:ok, %Conversation{} = conversation} = Chat.create_conversation(@valid_attrs)
      assert conversation.title == "some title"
    end

    test "create_conversation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_conversation(@invalid_attrs)
    end

    test "update_conversation/2 with valid data updates the conversation" do
      conversation = conversation_fixture()

      assert {:ok, %Conversation{} = conversation} =
               Chat.update_conversation(conversation, @update_attrs)

      assert conversation.title == "some updated title"
    end

    test "update_conversation/2 with invalid data returns error changeset" do
      conversation = conversation_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_conversation(conversation, @invalid_attrs)
      assert conversation == Chat.get_conversation!(conversation.id)
    end

    test "delete_conversation/1 deletes the conversation" do
      conversation = conversation_fixture()
      assert {:ok, %Conversation{}} = Chat.delete_conversation(conversation)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_conversation!(conversation.id) end
    end

    test "change_conversation/1 returns a conversation changeset" do
      conversation = conversation_fixture()
      assert %Ecto.Changeset{} = Chat.change_conversation(conversation)
    end
  end

  describe "messages" do
    alias Gather.Chat.Message

    @valid_attrs %{content: "some content"}
    @update_attrs %{content: "some updated content"}
    @invalid_attrs %{content: nil}

    test "list_messages/0 returns all messages" do
      user = user_fixture(%{email: "joe@example.com"})
      %{id: id, conversation: conversation} = message_fixture(%{user: user})
      assert [%Message{id: ^id, author: "joe"}] = Chat.list_messages(conversation)
    end

    test "get_message!/1 returns the message with given id" do
      %{id: id, content: content} = message_fixture()
      assert %{id: ^id, content: ^content} = Chat.get_message!(id)
    end

    test "create_message/1 with valid data creates a message" do
      user = user_fixture()
      conversation = conversation_fixture()
      assert {:ok, %Message{} = message} = Chat.create_message(user, conversation, @valid_attrs)
      assert message.content == "some content"
    end

    test "create_message/1 with invalid data returns error changeset" do
      user = user_fixture()
      conversation = conversation_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(user, conversation, @invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, %Message{} = message} = Chat.update_message(message, @update_attrs)
      assert message.content == "some updated content"
    end

    test "update_message/2 with invalid data returns error changeset" do
      %{id: id, content: content} = message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_message(message, @invalid_attrs)
      assert %Message{id: ^id, content: ^content} = Chat.get_message!(id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chat.change_message(message)
    end
  end
end
