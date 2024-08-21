defmodule EXKPasswdWeb.HomeLive do
  use EXKPasswdWeb, :live_view

  alias EXKPasswd.Presets

  @impl Phoenix.LiveView
  def mount(_params, _sessoin, socket) do
    socket =
      socket
      |> assign(presets: Presets.all())
      |> assign(settings: Presets.get(:default))

    {:ok, socket}
  end

  def handle_event("apply", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
end
