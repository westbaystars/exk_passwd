defmodule EXKPasswdWeb.HomeLive do
  use EXKPasswdWeb, :live_view

  alias EXKPasswd.Presets

  @impl Phoenix.LiveView
  def mount(_params, _sessoin, socket) do
    preset = Presets.get(:default)
    padding_type = if preset.pad_to_length > 0, do: :adaptive, else: :fixed

    socket =
      socket
      |> assign(presets: Presets.all())
      |> assign(settings: preset)
      |> assign(padding_type: padding_type)

    {:ok, socket}
  end

  def handle_event("apply", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
end
