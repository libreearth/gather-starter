defmodule GatherWeb.PageLiveTest do
  use GatherWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to our Gathering"
    assert render(page_live) =~ "Welcome to our Gathering"
  end
end
