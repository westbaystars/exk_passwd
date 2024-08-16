defmodule EXKPasswdWeb.HomeLive do
  use Phoenix.LiveView

  alias EXKPasswd.Presets

  @impl Phoenix.LiveView
  def mount(_params, _sessoin, socket) do
    socket = socket
    |> assign(presets: Presets.all())
    {:ok, socket}
  end
end
