defmodule GatherWeb.ConversationLive.FormComponent do
  use GatherWeb, :live_component

  alias Gather.Chat

  @impl true
  def update(%{conversation: conversation} = assigns, socket) do
    changeset = Chat.change_conversation(conversation)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"conversation" => conversation_params}, socket) do
    changeset =
      socket.assigns.conversation
      |> Chat.change_conversation(conversation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"conversation" => conversation_params}, socket) do
    save_conversation(socket, socket.assigns.action, conversation_params)
  end

  defp save_conversation(socket, :edit, conversation_params) do
    case Chat.update_conversation(socket.assigns.conversation, conversation_params) do
      {:ok, _conversation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversation updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_conversation(socket, :new, conversation_params) do
    case Chat.create_conversation(conversation_params) do
      {:ok, _conversation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversation created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
