defmodule EXKPasswdWeb.HomeLive do
  use EXKPasswdWeb, :live_view

  alias EXKPasswd.{Presets, Settings}

  @impl Phoenix.LiveView
  def mount(_params, _sessoin, socket) do
    preset = Presets.get("default")
    padding_type = if preset.pad_to_length > 0, do: "adaptive", else: "fixed"

    pad_to_length =
      if preset.pad_to_length > 0, do: preset.pad_to.length, else: calc_max_length(preset)

    socket =
      socket
      |> load_current_setting()
      |> assign(presets: Presets.all())
      |> assign(settings: preset)
      |> assign_form(Settings.changeset(preset, %{}))
      |> assign(accordian: "settings")
      |> assign(padding_type: padding_type)
      |> assign(pad_to_length: pad_to_length)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("apply", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "validate",
        %{"_target" => ["padding_type"], "padding_type" => padding_type},
        %{assigns: %{settings: settings, form: form, pad_to_length: pad_to_length}} = socket
      ) do
    pad_to_length = if padding_type == "fixed", do: "0", else: pad_to_length

    changeset =
      settings
      |> Settings.changeset(Map.merge(form.source.changes, %{:pad_to_length => pad_to_length}))
      |> Map.put(:action, :validate)

    IO.inspect({:padding_type, padding_type})

    {:noreply,
     socket
     |> assign(padding_type: padding_type)
     |> assign_form(changeset)}
  end

  def handle_event(
        "validate",
        %{"_target" => ["pad_to_length"], "pad_to_length" => "0"},
        %{assigns: %{settings: settings, form: form}} = socket
      ) do
    changeset =
      settings
      |> Settings.changeset(Map.merge(form.source.changes, %{:pad_to_length => "0"}))
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(padding_type: "fixed")
     |> assign_form(changeset)}
  end

  def handle_event(
        "validate",
        %{"_target" => ["pad_to_length"], "pad_to_length" => pad_to_length},
        %{assigns: %{settings: settings, form: form}} = socket
      ) do
    changeset =
      settings
      |> Settings.changeset(Map.merge(form.source.changes, %{:pad_to_length => pad_to_length}))
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(pad_to_length: pad_to_length)
     |> assign_form(changeset)}
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

  def handle_event("restoreSettings", %{"settings" => nil}, socket), do: {:noreply, socket}

  def handle_event(
        "restoreSettings",
        %{"settings" => settings},
        socket
      ) do
    IO.inspect(settings)

    changeset =
      Settings.changeset(%Settings{}, settings)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(settings: settings)
     |> assign_form(changeset)}
  end

  def handle_event(
        "save_settings",
        _params,
        %{assigns: %{settings: settings, form: form}} = socket
      ) do
    changeset =
      settings
      |> Settings.changeset(
        Map.merge(form.source.changes, %{
          name: "current",
          description: "The current working settings."
        })
      )

    IO.inspect(changeset, label: "Save Settings")

    {:noreply,
     socket
     |> save_settings(changeset)}
  end

  defp assign_form(socket, changeset) do
    socket
    |> assign(:form, to_form(changeset))
  end

  defp load_current_setting(socket) do
    if connected?(socket) do
      push_event(socket, "getSettings", %{name: "current"})
    else
      socket
    end
  end

  defp save_settings(socket, changeset) do
    with {:ok, settings} <- Ecto.Changeset.apply_action(changeset, :update) do
      IO.inspect(settings, label: "Save Settings")
      push_event(socket, "saveSettings", %{current: settings})
    else
      {:error, _changeset} -> socket
    end
  end

  defp calc_max_length(setting) do
    separator_length = if String.length(setting.separator_character) > 0, do: 1, else: 0

    setting.num_words * setting.word_length_max +
      (separator_length * setting.num_words - 1) +
      if(setting.digits_before > 0, do: setting.digits_before + separator_length, else: 0) +
      if(setting.digits_after > 0, do: setting.digits_after + separator_length, else: 0) +
      if(setting.padding_before > 0, do: setting.padding_before, else: 0) +
      if setting.padding_after > 0, do: setting.padding_after, else: 0
  end
end
