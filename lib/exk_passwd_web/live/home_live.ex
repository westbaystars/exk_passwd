defmodule EXKPasswdWeb.HomeLive do
  use EXKPasswdWeb, :live_view

  alias EXKPasswd.{Presets, Settings}

  @impl Phoenix.LiveView
  def mount(_params, _sessoin, socket) do
    preset = Presets.get("default")
    IO.inspect(preset, label: "Mounting")
    padding_type = if preset.pad_to_length > 0, do: :adaptive, else: :fixed

    socket =
      socket
      |> assign(presets: Presets.all())
      |> assign(settings: preset)
      |> assign_form(Settings.changeset(preset, %{}))
      |> assign(accordian: "settings")
      |> assign(padding_type: padding_type)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("apply", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "validate",
        %{"_target" => ["num_words"], "num_words" => num_words},
        %{assigns: %{settings: settings, form: form}} = socket
      ) do
    IO.inspect(form, label: "The form")

    with {num_words, _} <- Integer.parse(num_words) do
      changeset =
        settings
        |> Settings.changeset(Map.merge(form.source.changes, %{num_words: num_words}))
        |> Map.put(:action, :validate)

      {:noreply,
       socket
       |> assign_form(changeset)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Handle Event Default")}
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
