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
  <label class="form-control w-full max-w-xs">
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
