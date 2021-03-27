defmodule GatherWeb.ConversationLive.Show do
  use GatherWeb, :live_view

  alias Gather.{Accounts, Chat}
  alias Chat.{Conversation, Message}
  alias GatherWeb.Endpoint

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    {:ok,
     assign_new(socket, :current_user, fn ->
       Accounts.get_user_by_session_token(user_token)
     end)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    Endpoint.subscribe("conversation_#{id}")

    conversation = Chat.get_conversation!(id)
    messages = Chat.list_messages(conversation)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:conversation, conversation)
     |> assign(:messages, messages)}
  end

  @impl true
  def handle_event("send_message", %{"message" => message_params}, socket) do
    %{assigns: %{current_user: user, conversation: conversation}} = socket

    case Chat.create_message(user, conversation, message_params) do
      {:ok, _new_message} ->
        {:noreply, socket}

      {:error, changeset} ->
        IO.inspect({:error, changeset})
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{event: "create", payload: %Message{} = new_message}, socket) do
    updated_messages = socket.assigns.messages ++ [new_message]
    {:noreply, assign(socket, :messages, updated_messages)}
  end

  def handle_info(%{event: "update", payload: %Conversation{} = conversation}, socket) do
    IO.inspect("update!")
    {:noreply, assign(socket, :conversation, conversation)}
  end

  defp page_title(:show), do: "Show Conversation"
  defp page_title(:edit), do: "Edit Conversation"
end
