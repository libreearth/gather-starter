defmodule GatherWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `GatherWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, GatherWeb.ConversationLive.FormComponent,
        id: @conversation.id || :new,
        action: @live_action,
        conversation: @conversation,
        return_to: Routes.conversation_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    title = Keyword.fetch!(opts, :title)
    modal_opts = [id: :modal, return_to: path, title: title, component: component, opts: opts]
    live_component(socket, GatherWeb.ModalComponent, modal_opts)
  end
end
