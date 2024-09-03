defmodule EXKPasswdWeb.HomeLive do
  use EXKPasswdWeb, :live_view

  alias EXKPasswd.{Presets, Settings, PasswordCreator}

  @impl Phoenix.LiveView
  def mount(_params, _sessoin, socket) do
    preset = Presets.get("default")

    socket =
      socket
      |> load_current_setting()
      |> assign(presets: Presets.all())
      |> assign(settings: preset)
      |> assign_form(Settings.changeset(preset, %{}))
      |> assign_padding(preset)
      |> assign(passwords: [])

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
    changeset =
      Settings.changeset(%Settings{}, settings)
      |> Map.put(:action, :validate)

    {:ok, new_settings} = Ecto.Changeset.apply_action(changeset, :update)

    {:noreply,
     socket
     |> assign(settings: new_settings)
     |> assign_padding(new_settings)
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

    {:noreply,
     socket
     |> save_settings(changeset)}
  end

  def handle_event(
        "generate",
        %{"selectAmount" => count},
        %{assigns: %{form: form}} = socket
      ) do
    with (
           {:ok, settings} = Ecto.Changeset.apply_action(form.source, :update)
           {count, _} = Integer.parse(count)

           passwords =
             Enum.map(1..max(1, count), fn _n -> PasswordCreator.create(settings) end)
         ) do
      {:noreply,
       socket
       |> assign(passwords: Enum.join(passwords, "\n"))}
    else
      {:error, _} -> {:noreply, socket}
    end
  end

  def handle_event(
        "select-preset",
        %{"preset" => preset_name},
        socket
      ) do
    preset = Presets.get(preset_name)

    if preset == nil do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> assign(settings: preset)
       |> assign_form(Settings.changeset(preset, %{}))
       |> assign_padding(preset)}
    end
  end

  defp assign_padding(socket, setting) do
    padding_type = if setting.pad_to_length > 0, do: "adaptive", else: "fixed"

    pad_to_length =
      if setting.pad_to_length > 0, do: setting.pad_to_length, else: calc_max_length(setting)

    socket
    |> assign(padding_type: padding_type)
    |> assign(pad_to_length: pad_to_length)
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
