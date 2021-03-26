defmodule GatherWeb.ConversationLiveTest do
  use GatherWeb.ConnCase

  import Phoenix.LiveViewTest
  import Gather.AccountsFixtures

  alias Gather.Chat

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  defp fixture(:conversation) do
    {:ok, conversation} = Chat.create_conversation(@create_attrs)
    conversation
  end

  defp create_conversation(_) do
    conversation = fixture(:conversation)
    %{conversation: conversation}
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  describe "Index" do
    setup [:create_conversation, :create_user]

    test "lists all conversations", %{conn: conn, user: user, conversation: conversation} do
      {:ok, _index_live, html} =
        conn
        |> log_in_user(user)
        |> live(Routes.conversation_index_path(conn, :index))

      assert html =~ "Listing Conversations"
      assert html =~ conversation.title
    end

    test "saves new conversation", %{conn: conn, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(Routes.conversation_index_path(conn, :index))

      assert index_live |> element("a[href=\"/conversations/new\"]") |> render_click() =~
               "New Conversation"

      assert_patch(index_live, Routes.conversation_index_path(conn, :new))

      assert index_live
             |> form("#conversation-form", conversation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#conversation-form", conversation: @create_attrs)
        |> render_submit()
        |> follow_redirect(log_in_user(conn, user), Routes.conversation_index_path(conn, :index))

      assert html =~ "Conversation created successfully"
      assert html =~ "some title"
    end

    test "updates conversation in listing", %{conn: conn, user: user, conversation: conversation} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(Routes.conversation_index_path(conn, :index))

      assert index_live |> element("#conversation-#{conversation.id} a", "Edit") |> render_click() =~
               "Edit Conversation"

      assert_patch(index_live, Routes.conversation_index_path(conn, :edit, conversation))

      assert index_live
             |> form("#conversation-form", conversation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#conversation-form", conversation: @update_attrs)
        |> render_submit()
        |> follow_redirect(log_in_user(conn, user), Routes.conversation_index_path(conn, :index))

      assert html =~ "Conversation updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes conversation in listing", %{conn: conn, user: user, conversation: conversation} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(Routes.conversation_index_path(conn, :index))

      assert index_live
             |> element("#conversation-#{conversation.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#conversation-#{conversation.id}")
    end
  end

  describe "Show" do
    setup [:create_conversation, :create_user]

    test "displays conversation", %{conn: conn, user: user, conversation: conversation} do
      {:ok, _show_live, html} =
        conn
        |> log_in_user(user)
        |> live(Routes.conversation_show_path(conn, :show, conversation))

      assert html =~ "Show Conversation"
      assert html =~ conversation.title
    end

    test "updates conversation within modal", %{
      conn: conn,
      user: user,
      conversation: conversation
    } do
      {:ok, show_live, _html} =
        conn
        |> log_in_user(user)
        |> live(Routes.conversation_show_path(conn, :show, conversation))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Conversation"

      assert_patch(show_live, Routes.conversation_show_path(conn, :edit, conversation))

      assert show_live
             |> form("#conversation-form", conversation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#conversation-form", conversation: @update_attrs)
        |> render_submit()
        |> follow_redirect(log_in_user(conn, user), Routes.conversation_show_path(conn, :show, conversation))

      assert html =~ "Conversation updated successfully"
      assert html =~ "some updated title"
    end
  end
end
