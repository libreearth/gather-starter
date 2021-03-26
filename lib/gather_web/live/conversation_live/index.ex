defmodule GatherWeb.ConversationLive.Index do
  use GatherWeb, :live_view

  alias Gather.Chat
  alias Gather.Chat.Conversation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :conversations, list_conversations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Conversation")
    |> assign(:conversation, Chat.get_conversation!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Conversation")
    |> assign(:conversation, %Conversation{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Conversations")
    |> assign(:conversation, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    conversation = Chat.get_conversation!(id)
    {:ok, _} = Chat.delete_conversation(conversation)

    {:noreply, assign(socket, :conversations, list_conversations())}
  end

  defp list_conversations do
    Chat.list_conversations()
  end
end
