# Save Settings Take 2

Now that we have the settings accessible as `Changeset`s, let's use that and
the `lib/exk_passwd_web/components/core_components.ex` to clean up our
`home_live.html.heex` file while keeping the look of the components we output
consistent (without having to re-type all of the cleasses over and over).

The first component that we need is the one with the label joined to the
`input` box. I had commented out the error tag from the Official port,
but we're going to want to show that now, and the default `core_components`
has that built in as well (though I'd like to tweak it a bit).

Using the DaisyUI "[Text Input with form-control and labels]
(https://daisyui.com/components/input/#with-form-control-and-labels)" as
a base, replace the fall through `input` function as so:

```elixir
# All other inputs text, datetime-local, url, password, etc. are handled here...
def input(assigns) do
  ~H"""
  <label class="form-control w-full">
    <div class="join w-full flex flex-row">
      <label
        for={@id}
        class="font-normal items-center text-base text-center px-3 py-2 bg-gray-100 border rounded-l-lg border-zinc-300 flex-none"
      >
        <%= @label %>
      </label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "block text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "font-normal p-[.375rem .75rem] leading-normal border rounded-r-lg flex-auto w-1",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
    </div>
    <div class="label">
      <span class="label-text-alt">
        <.error :for={msg <- @errors}><%= msg %></.error>
      </span>
    </div>
  </label>
  """
end
```

This is a blend of DaisyUI Input Text, `CoreComponents.input` and the
hand-crafted label/input that we brought over from the Official port.

Next, the default `CoreComponents.error` just needs to have the `mt-3`
class taken off, as we really want the error to be up close to the
element it is warning us about.

```elixir
def error(assigns) do
  ~H"""
  <p class="flex gap-3 text-sm leading-6 text-rose-600">
    <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
    <%= render_slot(@inner_block) %>
  </p>
  """
end
```

Now let's go to `lib/exk_passwd_web/live/home_live.html.heex` and replace
all of the "# of words" label and input with:

```elixir
<div class="mt-2 col-span-6 md:col-span-3 lg:col-span-2">
  <.input
    type="number"
    min="1"
    max="10"
    step="1"
    id="num_words"
    name="num_words"
    label="# of words"
    field={@form[:num_words]}
  />
</div>
```

The encompansing `<div>` stays as is, since it handles placing the block of
tags on the page. Everything else is to build the label/input/error block.

Oh, and we have `field={@form[:num_words]}` instead of
`value={@settings.num_words}` now. We have a little bit more preparation
to make this work.

First of all, we're going to use the `CoreComponents.simple_form` to manage
the form data for us. So let's edit the `<form ...>` to read:

```elixir
<.simple_form for={@form} id="password-settings" phx-change="validate" phx-submit="apply">
  ...
</.simple_form>
 ```

 All of the other elements may remain the same for now. We'll handle them
 one at a time.

 Next, we need to add the `:form` to our assigns in `mount/3`:

 ```elixir
  @impl Phoenix.LiveView
  def handle_event(
        "validate",
        %{"_target" => ["num_words"], "num_words" => num_words},
        %{assigns: %{settings: settings, form: form}} = socket
      ) do
    changeset =
      settings
      |> Settings.changeset(Map.merge(form.source.changes, %{num_words: num_words}))
      |> Map.put(:action, :validate)

    {:noreply,
    socket
    |> assign_form(changeset)}
  end
```

`assign_form` is new. It needs to be added at to the bottom of the module:

```elixir
defp assign_form(socket, changeset) do
  assign(socket, :form, to_form(changeset))
end
```

I got this from "[Programming Phoenix LiveView]
(https://pragprog.com/titles/liveview/programming-phoenix-liveview/)" by
Bruce A. Tate and Sophie DeBenedetto.

It will now tell you that there is an error if you enter a number outside
of the range from 1 to 10. However, it also keeps switching back to the
`Presets` accordian. That's rather annoying.

### Retain Accordian over Edits

The accordian is controlled via a radio button in the always visible header
of the two accordian panels. When LiveView makes major changes, the radio
button is restored to its original state and it flips back to `Presets`
being active. Having to open the `Settings` panel after each change is not
a very good experience. So let's fix that.

```elixir
<div class="collapse collapse-arrow bg-base-200 border-base-300 border rounded-b-none">
  <input
    type="radio"
    name="accordian-content"
    class="w-full checked:bg-active"
    value="presets"
    checked={@accordian == "presets"}
  />
  <div class="collapse-title text-xl font-medium">
    Presets
  </div>
  ...
</div>
```

We're adding the `value="presets" and instead of `checked="checked"`, let's
have it dependent on an `assign` value, `@accordian`.

We need something simiar for the `Settings` panel:

```elixir
<div class="collapse collapse-arrow bg-base-200 border-base-300 border rounded-t-none">
  <input
    type="radio"
    name="accordian-content"
    value="settings"
    class="w-full checked:bg-active"
    checked={@accordian == "settings"}
  />
  <div class="collapse-title text-xl font-medium">
    Settings
  </div>
  ...
</div>
```

Here the value is `settings` and it is active when `@accordian == "settings".

Now we need to initialize `@accordian` in `mount/3`:

```elixir
...
|> assign_form(Settings.changeset(preset, %{}))
|> assign(accordian: "settings")
|> assign(padding_type: padding_type)
...
```

By setting to `settings` by default, we can keep on changing the `# of words`
without losing our form (or minds). Experiment with changing the value of
`# of words` to `0`, `10`, `30`, `8`, `1`, etc. Everything from 1 to 10
(inclusive) should be fine with anything outside of that range resulting in
a `must be between 1 and 10` error underneath and the edit box turning
red.

## Handling Min Length and Max Length Changes

Because we have already prepared the label/component/error element in
`core_components.ex`, we can use it and clean up our `home_live.html.heex`
file for `word_length_min` and `word_length_max` entry parameters.

```elixir
<div class="mt-2 col-span-6 md:col-span-3 lg:col-span-2">
    <.input
      type="number"
      min="4"
      max="10"
      step="1"
      id="word_length_min"
      name="word_length_min"
      label="Min Length"
      field={@form[:word_length_min]}
    />
</div>
<div class="mt-2 col-span-6 md:col-span-3 lg:col-span-2">
    <.input
      type="number"
      min="4"
      max="10"
      step="1"
      id="word_length_max"
      name="word_length_max"
      label="Max Length"
      field={@form[:word_length_max]}
    />
</div>
```

Word can be from 4 to 10 characters in length. And we're now getting the
data from the `@form` assign instead of the `@setting` default preset
that we originally setup in `mount/3`.

Now it's time to wire it up. In `home_live.ex`:

```elixir
def handle_event(
      "validate",
      %{"_target" => ["word_length_min"], "word_length_min" => word_length_min},
      %{assigns: %{settings: settings, form: form}} = socket
    ) do
  changeset =
    settings
    |> Settings.changeset(Map.merge(form.source.changes, %{word_length_min: word_length_min}))
    |> Map.put(:action, :validate)

  {:noreply,
   socket
   |> assign_form(changeset)}
end

def handle_event(
      "validate",
      %{"_target" => ["word_length_max"], "word_length_max" => word_length_max},
      %{assigns: %{settings: settings, form: form}} = socket
    ) do
  changeset =
    settings
    |> Settings.changeset(Map.merge(form.source.changes, %{word_length_max: word_length_max}))
    |> Map.put(:action, :validate)

  {:noreply,
   socket
   |> assign_form(changeset)}
end
```

These event handlers are very much like the handlers we wrote for `num_words`.
We take the value that was changed along with the `settings` and `form`.
The `settings` is converted to a `Changeset`, merging the changes so far
with the new value and the `action` is set to `:validate`. The `changeset`
is then converted to the `Phoenix.HTML.Form` struct and returned as an
assign to the page.

The last thing that needs to be done is that the min and max values need to
be validated in `settings.ex`.

```elixir
...
|> validate_inclusion(:num_words, 1..10, message: "must be between 1 and 10")
|> validate_inclusion(:word_length_min, 4..10, message: "must be between 4 and 10")
|> validate_inclusion(:word_length_max, 4..10, message: "must be between 4 and 10")
```

The last two validations are added to make sure that their values are between
4 and 10 (inclusive).

With this, we can now veryify that numbers entered less than 4 or greater
than 10 cause an error to be shown for both fields. But what happens when
the `Min Length` is greater than the `Max Length`? Nothing. That's
currently acceptable.

To fix that, let's write a custom validation.

```elixir
defp validate_less_than_or_equal(changeset, min, max, upper_label) do
  {_, min_value} = fetch_field(changeset, min)
  {_, max_value} = fetch_field(changeset, max)

  if min_value <= max_value do
    changeset
  else
    message = "must be <= to #{upper_label}"
    add_error(changeset, min, message, max_field: max)
  end
end
```

We get the min and max values, compare them, and if min is less than or
equal to max, return the `changeset` as is -- no problem. Otherwise,
add the error message to the min field for display.

And we need to call it in our validation pipeline:

```elixir
...
|> validate_inclusion(:num_words, 1..10, message: "must be between 1 and 10")
|> validate_inclusion(:word_length_min, 4..10, message: "must be between 4 and 10")
|> validate_inclusion(:word_length_max, 4..10, message: "must be between 4 and 10")
|> validate_less_than_or_equal(:word_length_min, :word_length_max, "Max Length")
```

Now if we change the `Min Length` to `6` and the `Max Length` to `4`, we
get the error `must be <= to Max Length` below the `Min Length` field.

## Case Transformations

Once again, we're going to modify a default `core_components.ex` element to
match the Official port in look and feel. Find the `type: "select` `input`
definition and replace it with:

```elixir
def input(%{type: "select"} = assigns) do
  ~H"""
  <label class="form-control w-full">
    <div class="join w-full w-max-full flex flex-row">
      <label
        for={@id}
        class="font-normal items-center text-base text-center px-3 py-2 bg-gray-100 border rounded-l-lg border-zinc-300 flex-none"
      >
        <%= @label %>
      </label>
      <select
        id={@id}
        name={@name}
        class="font-normal p-[.375rem .75rem] leading-normal border rounded-r-lg border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm flex-auto w-1"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
    </div>
    <.error :for={msg <- @errors}><%= msg %></.error>
  </label>
  """
end
```

Here we wrap the label, select, and error into a `form-control` and add
the classes that we used before.

Now, let's use this in `home_live.html.heex`:

```elixir
<!-- Word Transformations -->
<div
  id="section_transformations"
  class="grid grid-cols-1 w-full gap-1 mt-0 py-3 g-1"
>
  <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-1">
    Transformations
  </h5>
  <.input
    type="select"
    label="Case Transform"
    id="case_transform"
    name="case_transform"
    options={[
        "-none-": :none,
        "alternating WORD case": :alternate,
        "Capitalize First Letter": :capitalize,
        "cAPITALIZE eVERY lETTER eXCEPT tHe fIRST": :invert,
        "lower case": :lower,
        "UPPER CASE": :upper,
        "EVERY word randomly CAPITALIZED or NOT": :random
    ]}
    value={@form[:case_transform].value}
  />
</div>
<!-- /section_transformations -->
```

Finally, to wire this up in `home_live.ex`, we could add another event
handler for when `_target => ["case_transform"]`. But looking at the previous
ones, they are pretty much all the same except for what is being targetted.
Let's combine them all into a single `handle_event` function:

```elixir
def handle_event(
      "validate",
      %{"_target" => [target]} = params,
      %{assigns: %{settings: settings, form: form}} = socket
    ) do
  changeset =
    settings
    |> Settings.changeset(Map.merge(form.source.changes, %{String.to_existing_atom(target) => params[target]}))
    |> Map.put(:action, :validate)

  {:noreply,
   socket
   |> assign_form(changeset)}
end
```

Mysteriously, merging the maps worked fine when doing this in functions that
specified the `_target` and getting the parameter in the pattern matching, but
failed in this more general function. The problem was that the
`form.source.changes` was a map using atoms and this was merging that with
a `Map` with a string key. Turning the `target` to an atom (safely) got it
working again after more than one change has been made.

Pulling up the page in a browser and setting `# of words` to 0, `Min Length`
to `8` and `Max Lenth` to `3` should give us one error message under each of
the three `Words` entries. Changing `Case Transform` will output the `HANDLE
EVENT` message to the console, but the main thing is that it doesn't then
crash the page. You are welcome to insert an `IO.inspect` in the `assign_form`
function to verify that it has been chagned.

## Separator and Padding Inputs

We can now wizz through the Separator Character, Padding Digits (Before and
After), Padding Characters, Symbol Padding (Before and After), and Padding
Length. All of them are consolidating parameters to an `<.input ...>`
component.

```elixir
<!-- Separator -->
<div id="section_separator" class="grid grid-cols-1 w-full gap-1 mt-0 py-3 g-1">
  <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-1">
    Separator
  </h5>
  <div class="join w-full w-max-full flex flex-row">
    <.input
      type="text"
      id="separator_character"
      name="separator_character"
      label="Separator Character"
      field={@form[:separator_character]}
    />
  </div>
</div>
<!-- /section_separator -->
<!-- Padding -->
<div id="section_padding" class="grid grid-cols-2 w-full gap-1 mt-0 py-3 g-1">
  <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-2">Padding</h5>
  <div class="mt-2 col-span-2 md:col-span-1">
    <!-- padding digits before -->
    <.input
      type="number"
      min="0"
      max="5"
      step="1"
      id="digits_before"
      name="digits_before"
      label="Digit(s) Before"
      field={@form[:digits_before]}
    />
  </div>
  <!-- /padding_digits_before -->
  <div class="mt-2 col-span-2 md:col-span-1">
    <!-- padding digits after -->
    <.input
      type="number"
      min="0"
      max="5"
      step="1"
      id="digits_after"
      name="digits_after"
      label="Digit(s) After"
      field={@form[:digits_after]}
    />
  </div>
  <!-- /padding_digits_after -->
  <!-- padding_characters -->
  <div class="mt-2 col-span-2">
    <.input
      type="text"
      id="padding_character"
      name="padding_character"
      label="Padding Characters"
      field={@form[:padding_character]}
    />
  </div>
  <!-- /padding_characters -->
  <!-- place holder for Fixed Padding radio button -->
  <!-- padding characters before -->
  <div class="mt-2 col-span-2 md:col-span-1 pl-7">
    <.input
      type="number"
      min="0"
      max="5"
      step="1"
      id="padding_before"
      name="padding_before"
      label="Symbol(s) Before"
      field={@form[:padding_before]}
    />
  </div>
  <!-- /padding_characters_before -->
  <!-- padding characters after -->
  <div class="mt-2 col-span-2 md:col-span-1 pl-7 md:pl-0">
    <.input
      type="number"
      min="0"
      max="5"
      step="1"
      id="padding_after"
      name="padding_after"
      label="Symbol(s) After"
      field={@form[:padding_after]}
    />
  </div>
  <!-- /padding_characters_after -->
  <!-- place holder for Adaptive Padding radio button -->
  <div class="mt-2 col-span-2 pl-7">
    <.input
      type="number"
      min="8"
      max="999"
      step="1"
      id="pad_to_length"
      name="pad_to_length"
      label="Pad to Length"
      field={@form[:pad_to_length]}
    />
  </div>
  <!-- /pad_to_length -->
  <!-- /padding_char_container -->
</div>
<!-- /section_padding -->
```

We'll get to handling the radio buttons in a bit. For now, let's wire up the
value and/or size constraints for the `Separator` and `Padding` fields we
just updated.

In `settings.ex` add the following `validate_...` calls:

```elixir
...
|> validate_length(:separator_character, max: 20)
|> validate_inclusion(:digits_before, 0..5, message: "must be between 0 and 5")
|> validate_inclusion(:digits_after, 0..5, message: "must be between 0 and 5")
|> validate_length(:padding_character, min: 1, max: 20)
|> validate_inclusion(:pad_to_length, Enum.concat([0..0, 8..999]), message: "must be 0 or between 8 and 999")
|> validate_inclusion(:padding_before, 0..5, message: "must be between 0 and 5")
|> validate_inclusion(:padding_after, 0..5, message: "must be between 0 and 5")
```

Now if we go to the
browser and try to enter invalid data into the fields, such as negative
or decimal numbers into the `Digits` or `Symbols` padding size
fields, we'll get errors, as will numbers greater than `5`. Enter more
letters, number, or symbols into the `Separator` and `Padding Characters`
fields and you'll get a "`should be at most 20 character(s)`" message.

## Fixed and Adaptive Padding

Notice how the `Symbol(s) Before`/`After` and `Pad to Length` elements are
indented under `Padding Characters`? We want these to be controlled by a
pair of radio buttons, so one is selected or the other. The way this works
is that, if `pad_to_length` value is greater than zero, then `Adaptive
Padding` is active. Otherwise, `Fixed Padding` is. Let's go to our
`mount/3` function and codify that:

```elixir
  preset = Presets.get("default")
  padding_type = if preset.pad_to_length > 0, do: "adaptive", else: "fixed"
  ...
  |> assign(padding_type: padding_type)
```

In the place holder for `Fixed Padding` the we made above, let's add:

```elixir
<div class="mt-2 col-span-2">
  <div class="join w-full w-max-full flex flex-row">
    <input
      type="radio"
      value="fixed"
      class="flex-none"
      name="padding_type"
      id="padding_fixed"
      checked={@padding_type == "fixed"}
    />
    <label
      for="padding_fixed"
      class="font-normal items-center text-base text-center px-3 flex-none"
    >
      Fixed Padding
    </label>
  </div>
</div>
```

And the place holder for `Adaptive Padding` gets a similar radio button:

```elixir
<div class="mt-2 col-span-2">
  <div class="join w-full w-max-full flex flex-row">
    <input
      type="radio"
      value="adaptive"
      class="flex-none"
      name="padding_type"
      id="padding_adaptive"
      checked={@padding_type != "fixed"}
    />
    <label
      for="padding_adaptive"
      class="font-normal items-center text-base text-center px-3 flex-none"
    >
      Adaptive Padding
    </label>
  </div>
</div>
```

Finally, before the the general `_target` event handler, let's add:

```elixir
def handle_event(
      "validate",
      %{"_target" => ["padding_type"], "padding_type" => padding_type},
      socket
    ) do
  {:noreply,
   socket
   |> assign(padding_type: padding_type)
  }
end
```

I now want to enable and disable the relavant entry elements depending on
which radio button is active. For that, let's add the:

```elixir
  disabled={@padding_type != "fixed"}
```

to both of the `Symbol` fixed padding elements and:

```elixir
  disabled={@padding_type == "fixed"}
```

to the `Pad to Length` adaptive padding element. Then, in `core_components.ex`,
extend the `class` definition to change the font weight depending on if it
is disabled or not:

```elixir
  class={[
    "block text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
    "font-normal p-[.375rem .75rem] leading-normal border rounded-r-lg flex-auto w-1",
    @errors == [] && "border-zinc-300 focus:border-zinc-400",
    @errors != [] && "border-rose-400 focus:border-rose-400",
    Map.get(@rest, :disabled, false) && "text-zinc-300",
    Map.get(@rest, :disabled, true) && "text-zinc-900"
  ]}
  {@rest}
```

Now the value grays out when the input element is disabled, which helps the
usability a lot.

That's fine, but what we really need is for the `Adaptive Padding` length
value to be greater than zero when it is selected and zero when the `Fixed`
option is selected. We're going to need to save the value entered when
the radio button is toggled to and away, so let's have a stand alone
`pad_to_length` value in the state along with the one in the `@form`
struct.

In `home_live.ex`, add the following within `mount/3` and the
`calc_max_length` function at the bottom:

```elixir
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
    |> assign(pad_to_length: pad_to_length)

  {:ok, socket}
end

...

defp calc_max_length(setting) do
  separator_length = if String.length(setting.separator_character) > 0, do: 1, else: 0

  (setting.num_words * setting.word_length_max) +
  (separator_length * setting.num_words - 1) +
  (if setting.digits_before > 0, do: setting.digits_before + separator_length, else: 0) +
  (if setting.digits_after > 0, do: setting.digits_after + separator_length, else: 0) +
  (if setting.padding_before > 0, do: setting.padding_before, else: 0) +
  (if setting.padding_after > 0, do: setting.padding_after, else: 0)
end
```

Then, when we handle the `:padding_type` event handler, we set the `@form`
to either `0` or our stateful `:pad_to_length`. Furthermore, we need a
handler for when `:pad_to_length` is changed, placing the modified stateful
value into the `@form` and its `assign`.

```elixir
def handle_event(
      "validate",
      %{"_target" => ["padding_type"], "padding_type" => padding_type},
      %{assigns: %{settings: settings, form: form, pad_to_length: pad_to_length}} = socket
    ) do
      pad_to_length = if padding_type == "fixed", do: "0", else: pad_to_length
  changeset =
    settings
    |> Settings.changeset(
      Map.merge(form.source.changes, %{:pad_to_length => pad_to_length})
    )
    |> Map.put(:action, :validate)
  IO.inspect({:padding_type, padding_type})
  {:noreply,
   socket
   |> assign(padding_type: padding_type)
   |> assign_form(changeset)
  }
end

def handle_event(
      "validate",
      %{"_target" => ["pad_to_length"], "pad_to_length" => pad_to_length},
      %{assigns: %{settings: settings, form: form}} = socket
    ) do
  changeset =
    settings
    |> Settings.changeset(
      Map.merge(form.source.changes, %{:pad_to_length => pad_to_length})
    )
    |> Map.put(:action, :validate)
  {:noreply,
   socket
   |> assign(pad_to_length: pad_to_length)
   |> assign_form(changeset)
  }
end
```

Fuzzing a bit in the browser, while `Fixed Padding` is selected, the
`Pad to Length` remains zero. `Symbol(s) Before` and `After` bring up
errors when exceeding `5` or negative number. With `Adaptive Padding`
selected, negative numbers, numbers `1..7`, and numbers `1,000` or
greater give us errors for that field.

However, we can set the `Pad to Length` to zero manually while `Adaptive
Padding` is enabled. That should not be allowed. If one manually sets
`Pad to Length` to zero, let's automatically flip back to `Fixed Padding`.

Between the above two event handlers, add the case when
`"pad_to_length" => "0"`:

```elixir
def handle_event(
      "validate",
      %{"_target" => ["pad_to_length"], "pad_to_length" => "0"},
      %{assigns: %{settings: settings, form: form}} = socket
    ) do
  changeset =
    settings
    |> Settings.changeset(
      Map.merge(form.source.changes, %{:pad_to_length => "0"})
    )
    |> Map.put(:action, :validate)
  {:noreply,
   socket
   |> assign(padding_type: "fixed")
   |> assign_form(changeset)
  }
end
```

We update the changeset to set `:pad_to_length` to zero, then set the
`@adding_type` to `"fixed"`, toggling the radio button back. In the browser,
if we then toggle back to `Adaptive Padding`, then the previous value for
`Pad to Length` is still there, not zero. So it is clear that the `Fixed
Padding` will be used.
