defmodule EXKPasswdWeb.HomeLive do
  use EXKPasswdWeb, :live_view

  alias EXKPasswd.{Presets, PasswordCreator, Settings}

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

  @impl Phoenix.LiveView
  def handle_event("apply", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"_target" => ["num_words"], "num_words" => num_words}, socket) do
    settings = socket.assigns.settings
    num_words = s_to_i(num_words)

    socket =
      cond do
        num_words < 1 ->
          socket
          # |> put_flash(:error, "Enter a number between 1 and 10")
          #|> assign(settings: %PasswordCreator{settings | num_words: 1})

        num_words > 10 ->
          socket
          # |> put_flash(:error, "Enter a number between 1 and 10")
          #|> assign(settings: %{settings | num_words: 10})

        num_words == :error ->
          socket

        # |> put_flash(:error, "Enter a number between 1 and 10")
        # |> assign(settings: %{settings | num_words: 3})
        true ->
          socket
          # |> put_flash(:info, "num_words set to #{num_words}")
          # |> assign(socket, settings: %{settings | num_words: num_words})
      end

    {:noreply, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Handle Event Default")}
  end

  # Returns either the string converted to an integer or `:error` if it is not an integer.
  defp s_to_i(string) when is_binary(string) do
    with {value, _} <- Integer.parse(string) do
      value
    else
      _ -> :error
    end
  end
end
