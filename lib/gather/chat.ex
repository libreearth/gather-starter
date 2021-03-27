defmodule Gather.Chat do
  @moduledoc """
  The Chat context.
  """

  import Ecto.Query, warn: false

  alias Gather.{Chat, Repo}
  alias Chat.{Conversation, Message}
  alias GatherWeb.Endpoint

  @doc """
  Returns the list of conversations.

  ## Examples

      iex> list_conversations()
      [%Conversation{}, ...]

  """
  def list_conversations do
    Conversation
    |> order_by(desc: :id)
    |> Repo.all()
  end

  @doc """
  Gets a single conversation.

  Raises `Ecto.NoResultsError` if the Conversation does not exist.

  ## Examples

      iex> get_conversation!(123)
      %Conversation{}

      iex> get_conversation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_conversation!(id), do: Repo.get!(Conversation, id)

  @doc """
  Creates a conversation.

  ## Examples

      iex> create_conversation(%{field: value})
      {:ok, %Conversation{}}

      iex> create_conversation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation(attrs \\ %{}) do
    %Conversation{}
    |> Conversation.changeset(attrs)
    |> Repo.insert()
    |> broadcast_conversation(:create)
  end

  @doc """
  Updates a conversation.

  ## Examples

      iex> update_conversation(conversation, %{field: new_value})
      {:ok, %Conversation{}}

      iex> update_conversation(conversation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation(%Conversation{} = conversation, attrs) do
    conversation
    |> Conversation.changeset(attrs)
    |> Repo.update()
    |> broadcast_conversation(:update)
  end

  defp broadcast_conversation({:ok, conversation}, action) do
    topic = "conversations"
    event = to_string(action)
    Endpoint.broadcast!(topic, event, conversation)

    topic = "conversation_#{conversation.id}"
    Endpoint.broadcast!(topic, event, conversation)

    {:ok, conversation}
  end

  defp broadcast_conversation(error, _action), do: error

  @doc """
  Deletes a conversation.

  ## Examples

      iex> delete_conversation(conversation)
      {:ok, %Conversation{}}

      iex> delete_conversation(conversation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversation(%Conversation{} = conversation) do
    conversation
    |> Repo.delete()
    |> broadcast_conversation(:delete)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversation changes.

  ## Examples

      iex> change_conversation(conversation)
      %Ecto.Changeset{data: %Conversation{}}

  """
  def change_conversation(%Conversation{} = conversation, attrs \\ %{}) do
    Conversation.changeset(conversation, attrs)
  end

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages(conversation)
      [%Message{}, ...]

  """
  def list_messages(conversation) do
    conversation
    |> Ecto.assoc(:messages)
    |> order_by(asc: :id)
    |> Repo.all()
    |> Repo.preload(:user)
    |> with_author()
  end

  defp with_author(messages) when is_list(messages) do
    Enum.map(messages, &with_author/1)
  end

  defp with_author(%Message{} = message) do
    [author | _rest] = String.split(message.user.email, "@")
    %Message{message | author: author}
  end

  defp with_author({:ok, message}) do
    {:ok, with_author(message)}
  end

  defp with_author(error), do: error

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(user, conversation, %{field: value})
      {:ok, %Message{}}

      iex> create_message(user, conversation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(user, conversation, attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:conversation, conversation)
    |> Repo.insert()
    |> with_author()
    |> broadcast_message(:create)
  end

  defp broadcast_message({:ok, message}, action) do
    topic = "conversation_#{message.conversation_id}"
    event = to_string(action)
    Endpoint.broadcast!(topic, event, message)
    {:ok, message}
  end

  defp broadcast_message(error, _action), do: error

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
    |> with_author()
    |> broadcast_message(:update)
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    message
    |> Repo.delete()
    |> broadcast_message(:delete)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
