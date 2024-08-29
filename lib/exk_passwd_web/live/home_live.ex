defmodule EXKPasswdWeb.HomeLive do
  use EXKPasswdWeb, :live_view

  alias EXKPasswd.{Presets, Settings}

  @impl Phoenix.LiveView
  def mount(_params, _sessoin, socket) do
    preset = Presets.get("default")
    padding_type = if preset.pad_to_length > 0, do: "adaptive", else: "fixed"
    pad_to_length = if preset.pad_to_length > 0, do: preset.pad_to.length, else: calc_max_length(preset)

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

  def handle_event(
        "validate",
        %{"_target" => ["padding_type"], "padding_type" => padding_type},
        %{assigns: %{settings: settings, form: form}} = socket
      ) do
#    changeset =
#      settings
#      |> Settings.changeset(
#        Map.merge(form.source.changes, %{String.to_existing_atom(target) => params[target]})
#      )
#      |> Map.put(:action, :validate)
    IO.inspect({:padding_type, padding_type})
    {:noreply,
     socket
     |> assign(padding_type: padding_type)
#     |> assign_form(changeset)
    }
  end

  def handle_event(
        "validate",
        %{"_target" => [target]} = params,
        %{assigns: %{settings: settings, form: form}} = socket
      ) do
    changeset =
      settings
      |> Settings.changeset(
        Map.merge(form.source.changes, %{String.to_existing_atom(target) => params[target]})
      )
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp calc_max_length(setting) do
    separator_length = if String.length(setting.separator_character) > 0, do: 1, else: 0

    (setting.num_words * setting.word_length_max) +
    (separator_length * setting.num_words - 1) +
    (if setting.digits_before > 0, do: setting.digits_before + separator_length, else: 0) +
    (if setting.digits_after > 0, do: setting.digits_after + separator_length, else: 0) +
    (if setting.padding_before > 0, do: setting.padding_before, else: 0) +
    (if setting.padding_after > 0, do: setting.padding_after, else: 0)
  end
end
